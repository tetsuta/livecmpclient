# Description of livecmpclient
Telegram client for live competition.
This repository provides 1) client function for chat and 2) evaluation function for the competition.

# client
- Edit ./localconfig.rb
- Start client script with a specific bot name.
  ./test_client.rb -b botname_bot
- If the script founds the bot, you can start conversation.
- Send "quit" to terminate the conversation.

example
````
./test_client.rb -b livecomptt_bot
````

# dialogue extraction

example
````
./dialogue_extraction.rb -b livecomptt_bot -n 5
````


# evaluation page

URL for form must be set in "data/form_iframe" in advance.

example
````
RESET
./generate_evalpage.rb -e -b IRSbot -t IRS1
./generate_evalpage.rb -e -b livecompeBaseline2021situ_bot -t livecompeBaseline2021situ1

upload
./generate_evalpage.rb -b IRSbot -t IRS1
./generate_evalpage.rb -b livecompeBaseline2021situ_bot -t livecompeBaseline2021situ1
````

http://www.kagonma.org/dialog/lc4/IRS1.html
http://www.kagonma.org/dialog/lc4/livecompeBaseline2021situ1.html


# evaluation server
A web server that send updated utterances to web clients.
````
./evaluation_server.rb -b livecomptt_bot
````

DSLC4bot
IRSbot

# connection
http://localhost/livecmp/eval.html
http://localhost/livecmp/polling.html


# reference
https://www.rubydoc.info/gems/tdlib-ruby/2.2.0/TD/ClientMethods#get_chat_message_by_date-instance_method
https://www.rubydoc.info/gems/tdlib-ruby/2.2.0/TD/Types/Messages
https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1search_public_chat.html
