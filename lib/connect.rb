#!/usr/local/bin/ruby
# coding: utf-8

require 'json'
require 'net/http'

host = 'localhost'
port = 8100

http = Net::HTTP.start(host, port)
path = "/"
header = {'Content-Type' => 'application/json'}

data = Hash::new()
data["input"] = "input data"
response = http.post(path, JSON.generate(data), header)
puts "--------------------"
p response
puts "--"
p response.body
puts "--------------------"

