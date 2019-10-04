#!/opt/gitlab/embedded/bin/ruby
require 'json'

# parse our inputs
ARGS = JSON.parse(STDIN.read)

# We only want to trigger this plugin on the event project_create
# return unless ARGS['object_kind'] == 'pipeline'

# dump our input to a log file
File.write('/tmp/rb-data.txt', ARGS.to_json, mode: 'o')
