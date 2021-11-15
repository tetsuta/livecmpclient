#!/usr/local/bin/ruby
# coding: utf-8

require 'webrick'
require 'net/protocol'
require 'securerandom'
require 'getoptlong'
require 'logger'
require 'net/protocol'

require_relative './config'
require_relative './td_fetch_server'

# -------------------------------------------------- #
opts = GetoptLong.new( [ "--bot_name", "-b", GetoptLong::REQUIRED_ARGUMENT ],
                       [ "--help", "-h", GetoptLong::NO_ARGUMENT ] )

def printHelp(message)
  STDERR.print message
  exit(1)
end

USAGE_MESSAGE = "
Extract recent messages

Usage:
 ./evaluation_server.rb [-h] -b bot_name_bot

-h: show help messsage
-b: bot_name
"

bot_name = nil
opts.each{|opt, arg|
  case opt
  when "--help"
    printHelp(USAGE_MESSAGE)
  when "--bot_name"
    bot_name = arg
  end
}

if bot_name == nil
  printHelp(USAGE_MESSAGE)
end

# --------------------------------------------------
def store_result(bot_name, userInput)
  data = {
    bot: bot_name,
    id: userInput["evalId"],
    dialogueEval: userInput["dialogueEvalResult"],
    utteranceEval: userInput["utteranceEvalResult"],
    timestamp: Time.now()
  }
  File.open("output/#{bot_name}","a+"){|wfp|
    wfp.puts JSON.generate(data)
  }
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

telegram_fetch = Telegram_Fetch.new(TDLIB_PATH, API_ID, API_HASH, Dialogue_History_Cache_Time, Dialogue_History_Stab_File)
telegram_fetch.select_chat(bot_name)

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
    data["html"] = ""

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
    mode = userInput["mode"]

    case mode
    when "getDialogue"
      $logger.info("connection: :#{request.peeraddr.to_s}")
      dialogue_history = telegram_fetch.load_history()
      data["text"] << dialogue_history.to_s
      data["html"] << dialogue_history.to_html
      response.body = JSON.generate(data)
    when "sendResult"
      store_result(bot_name, userInput)
      puts userInput["evalId"]
      puts userInput["dialogueEvalResult"]
      puts userInput["utteranceEvalResult"]
      $logger.info("connection: :#{request.peeraddr.to_s}")
      data["text"] = "done"
      response.body = JSON.generate(data)
    end

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
telegram_fetch.close()


