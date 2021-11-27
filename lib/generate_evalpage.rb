#!/usr/local/bin/ruby
# coding: utf-8

require 'getoptlong'
require_relative './config'
require_relative './td_fetch_server'

# -------------------------------------------------- #
opts = GetoptLong.new(
 		      [ "--bot_name", "-b", GetoptLong::REQUIRED_ARGUMENT ],
 		      [ "--target_name", "-t", GetoptLong::REQUIRED_ARGUMENT ],
		      [ "--empty", "-e", GetoptLong::NO_ARGUMENT ],
		      [ "--help", "-h", GetoptLong::NO_ARGUMENT ]
		      )

def printHelp(message)
  STDERR.print message
  exit(1)
end

USAGE_MESSAGE = "
Extract recent messages

Usage:
 ./generate_evalpage.rb [-h] -b bot_name_bot -t target_name

-h: show help messsage
-b: bot_name
-t: target_name
"

bot_name = nil
target_name = nil
empty = nil
opts.each{|opt, arg|
  case opt
  when "--help"
    printHelp(USAGE_MESSAGE)
  when "--empty"
    empty = true
  when "--bot_name"
    bot_name = arg
  when "--target_name"
    target_name = arg
  end
}

if bot_name == nil || target_name == nil
  printHelp(USAGE_MESSAGE)
end

# --------------------------------------------------
html_header = <<HEADER
<!doctype html>
<html lang="en-US">
<head>
  <title>live competition evaluation</title>

  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
  <meta http-equiv="Content-Type" content="text/html">

  <link rel="stylesheet" href="css/bootstrap.min.css" type="text/css">
  <link rel="stylesheet" href="css/base.css" type="text/css" media="all" />
  <script type="text/javascript" src="js/jquery-1.11.2.min.js"></script>
  <script type="text/javascript" src="js/eval.js"></script>
  <script type="text/javascript" src="js/bootstrap.min.js"></script>
</head>

<body>
  <div class="container">
    <div id="note"></div>
      
    <h1>ライブコンペ評価：#{target_name}</h1>

    <hr>
HEADER

html_footer = <<FOOTER
    <hr>

  </div><!-- /container -->

</body>
</html>
FOOTER

# --------------------------------------------------
iframe_url = Hash::new()
File.open(IFRAME_FILE){|fp|
  fp.each{|line|
    elems = line.chomp.split("\t")
    if elems.size == 2
      iframe_url[elems[0]] = elems[1]
    end
  }
}

unless iframe_url.has_key?(target_name)
  STDERR.puts("Set iframe URL in #{IFRAME_FILE}")
  exit
end

# --------------------------------------------------

telegram_fetch = Telegram_Fetch.new(TDLIB_PATH, API_ID, API_HASH, Dialogue_History_Cache_Time, Dialogue_History_Stab_File)

html_fp = File.open("html/#{target_name}.html","w")
html_fp.puts html_header

unless empty
  telegram_fetch.select_chat(bot_name)
  dialogue_history = telegram_fetch.load_history()
  html_fp.puts dialogue_history.to_html

  html_fp.puts "<hr>"
  html_fp.puts "<div id=\"selected_ids\"></div>"

  html_fp.puts iframe_url[target_name]
end


html_fp.puts html_footer
telegram_fetch.close()
html_fp.close


ftp_fp = File.open("upload","w")
ftp_fp.puts "open sss004.kix.ad.jp"
ftp_fp.puts "user ex0090025159 Tsukiage123"
ftp_fp.puts "bin"
ftp_fp.puts "prompt"
ftp_fp.puts "cd kagonma.stepserver.jp"
ftp_fp.puts "cd public_html/dialog/lc4"
ftp_fp.puts "lcd html"
ftp_fp.puts "put #{target_name}.html"
ftp_fp.puts "quit"
ftp_fp.close

put_command = "tnftp -n < upload"
system(put_command)

