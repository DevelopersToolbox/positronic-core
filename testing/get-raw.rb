#!/usr/bin/env ruby

require 'json'

$LOAD_PATH.unshift('./lib')

require 'bundler/setup'
require 'caretaker-core'

begin
    results = CaretakerCore.run
rescue StandardError => e
    puts e.message
    exit
end

puts JSON.pretty_generate(JSON.parse(results))
