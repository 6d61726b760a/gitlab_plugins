#!/opt/gitlab/embedded/bin/ruby
# By using the embedded ruby version we eliminate the possibility
# that our chosen language would be unavailable

# https://docs.gitlab.com/ee/administration/plugins.html

require 'net/http'
require 'uri'
require 'json'

LOGFILE = '/tmp/gitlab_pushevent_splunk_plugin.log'

# parse our input
ARGS = JSON.parse(STDIN.read)

# we only want to do something if this is a pipeline object
return unless ARGS['event_name'] == 'push'

# splunk url,headers etc
uri = URI.parse("https://your-splunk-endpoint:443/services/collector/event")
headers = {
  'Authorization' => 'Splunk XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
  'Content-Type' => 'application/json',
  'Accept' => 'application/json'
  }

# create our splunk payload
payload = {
  'index' => 'test_index',
  'sourcetype' => 'gitlab:push',
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
    'commit' => ARGS['checkout_sha'],
    'splunk_response' => splunk_response
}

# log the response/result
open(LOGFILE, 'a+') do |f|
      f.puts logmsg
end
