#!/usr/local/bin/ruby
# coding: utf-8

require 'webrick'
require 'net/protocol'
require 'securerandom'
require 'getoptlong'
require 'logger'
require 'net/protocol'
require 'pp'

require_relative './config'
require_relative './client'

# -------------------------------------------------- #
opts = GetoptLong.new( [ "--bot_name", "-b", GetoptLong::REQUIRED_ARGUMENT ],
                       [ "--number", "-n", GetoptLong::REQUIRED_ARGUMENT ],
                       [ "--help", "-h", GetoptLong::NO_ARGUMENT ] )

def printHelp(message)
  STDERR.print message
  exit(1)
end

USAGE_MESSAGE = "
Extract recent messages

Usage:
 ./evaluation_server.rb [-h] -b bot_name_bot -n 5

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
$logger = Logger.new(LogFile, LogAge, LogSize*1024*1024)
case LogLevel
when :fatal then
  $logger.level = Logger::FATAL
when :error then
  $logger.level = Logger::ERROR
when :warn then
  $logger.level = Logger::WARN
when :info then
  $logger.level = Logger::INFO
when :debug then
  $logger.level = Logger::DEBUG
end



options = {
  :Port => SystemPort,
  :BindAddress => SystemBindAddress,
  :DoNotReverseLookup => true
}

s = WEBrick::HTTPServer.new(options)


s.mount_proc('/'){|request, response|
  errormsg = "request body error."
  begin
    data = Hash::new
    data["text"] = ""

    if (request.request_method != "POST")
      errormsg = "HTTP method error."
      raise ArgumentError.new(errormsg)
    end
    if (request.content_type == nil)
      errormsg = "content-type error."
      raise ArgumentError.new(errormsg)
    end
    if (request.body == nil)
      errormsg = "request body error. bodysize=nil"
      raise ArgumentError.new(errormsg)
    end

    userInput = JSON.parse(request.body)
    input = userInput["input"]

    $logger.info("connection: :#{request.peeraddr.to_s}")
    data["text"] << Time.now.to_s
    response.body = JSON.generate(data)

  rescue Exception => e
    $logger.fatal(e.message)
    $logger.fatal(e.class)
    $logger.fatal e.backtrace
    errdata = Hash::new
    errbody = Hash::new
    case e
    when Net::ReadTimeout then
      response.status = 408
    when Net::ProtoAuthError then
      response.status = 401
    else
      response.status = 500
    end
    errbody["code"] = response.status
    errbody["message"] = e.message
    errdata["error"] = errbody
    response.body = JSON.generate(errdata)
  ensure
    if (HTTPAccessControl != nil && HTTPAccessControl != "")
      response.header["Access-Control-Allow-Origin"] = HTTPAccessControl
    end
    response.content_type = "application/json; charset=UTF-8"
  end
}

Signal.trap(:INT){
  s.shutdown
}

s.start



# telegram = Simple_TD.new(TDLIB_PATH, API_ID, API_HASH)
# telegram.select_chat(bot_name)
# if telegram.ready_to_talk?
#   message_list = telegram.get_recent_messages(number_of_message)
#   puts message_list.size
#   message_list.each{|m|
#     p m
#   }
# end
# puts "Closing..."
# telegram.close()

