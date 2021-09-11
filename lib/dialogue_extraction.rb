#!/usr/local/bin/ruby
# coding: utf-8

require 'getoptlong'
require './localconfig'
require './client'

# -------------------------------------------------- #
opts = GetoptLong.new(
 		      [ "--bot_name", "-b", GetoptLong::REQUIRED_ARGUMENT ],
 		      [ "--number", "-n", GetoptLong::REQUIRED_ARGUMENT ],
		      [ "--help", "-h", GetoptLong::NO_ARGUMENT ]
		      )

def printHelp(message)
  STDERR.print message
  exit(1)
end

USAGE_MESSAGE = "
Extract recent messages

Usage:
 ./dialogue_extraction.rb [-h] -b bot_name_bot -n 5

-h: show help messsage
-b: bot_name
-n: number of messages
"

bot_name = nil
number_of_message = nil
opts.each{|opt, arg|
  case opt
  when "--help"
    printHelp(USAGE_MESSAGE)
  when "--bot_name"
    bot_name = arg
  when "--number"
    number_of_message = arg.to_i
  end
}

if bot_name == nil || number_of_message == nil
  printHelp(USAGE_MESSAGE)
end

# --------------------------------------------------
telegram = Simple_TD.new(TDLIB_PATH, API_ID, API_HASH)
telegram.select_chat(bot_name)

if telegram.ready_to_talk?
  message_list = telegram.get_recent_messages(number_of_message)
  puts message_list.size
  message_list.each{|m|
    p m
  }
end

puts "Closing..."
telegram.close()

