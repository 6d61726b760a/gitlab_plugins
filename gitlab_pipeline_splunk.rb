#!/opt/gitlab/embedded/bin/ruby
# By using the embedded ruby version we eliminate the possibility
# that our chosen language would be unavailable

# https://docs.gitlab.com/ee/administration/plugins.html

require 'net/http'
require 'uri'
require 'json'

# parse our input
ARGS = JSON.parse(STDIN.read)

# we only want to do something if this is a pipeline object and it has completed
return unless ARGS['object_kind'] == 'pipeline' and %w(success failed canceled).include?(ARGS['object_attributes']['status'])

# splunk url,headers etc
uri = URI.parse("https://your-splunk-endpoint:443/services/collector/event")
headers = {
  'Authorization' => 'Splunk BNJ29X74-82C3-4283-4GT8-L4GW6RGS334J',
  'Content-Type' => 'application/json',
  'Accept' => 'application/json'
  }

# create our splunk payload
payload = {
  'index' => 'test_index',
  'sourcetype' => 'gitlab:pipeline',
  'event' => ARGS
}

# create http objects
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, headers)
request.body = payload.to_json

# send our request
response = http.request(request)

# get our http response
splunk_response = JSON.parse(response.body)
logmsg = {
    'time' => Time.now,
    'pipeline_id' => ARGS['object_attributes']['id'],
    'splunk_response' => splunk_response
}

# log the response/result
File.write('/tmp/gitlab_splunk_plugin.log', logmsg, mode: 'a+')
File.write('/tmp/gitlab_splunk_plugin.log', "\n", mode: 'a+')
