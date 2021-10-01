#!/usr/local/bin/ruby
# coding: utf-8

require 'getoptlong'
require './localconfig'
require './client'

# -------------------------------------------------- #
opts = GetoptLong.new(
 		      [ "--bot_name", "-b", GetoptLong::REQUIRED_ARGUMENT ],
		      [ "--quiet", "-q", GetoptLong::NO_ARGUMENT ],
		      [ "--help", "-h", GetoptLong::NO_ARGUMENT ]
		      )

def printHelp(message)
  STDERR.print message
  exit(1)
end

USAGE_MESSAGE = "
Usage:
 ./test_client.rb [-h] [-q] -b bot_name_bot

-h: show help messsage
-q: quiet mode
-b: bot_name
"

bot_name = nil
quiet = false
opts.each{|opt, arg|
  case opt
  when "--help"
    printHelp(USAGE_MESSAGE)
  when "--quiet"
    quiet = true
  when "--bot_name"
    bot_name = arg
  end
}

if bot_name == nil
  printHelp(USAGE_MESSAGE)
end

# --------------------------------------------------
telegram = Simple_TD.new(TDLIB_PATH, API_ID, API_HASH, quiet)
telegram.select_chat(bot_name)

if telegram.ready_to_talk?
  loop do
    print "> "
    input_message = STDIN.gets.strip
    case input_message
    when /quit/
      break
    else
      telegram.send_message(input_message)
      puts telegram.get_response_message()
    end
  end
end

puts "Closing..."
telegram.close()

