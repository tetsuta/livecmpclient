# Description of livecmpclient
Telegram client for live competition.
This repository provides 1) client function for chat and 2) evaluation function for the competition.

# client
- Edit ./localconfig.rb
- Start client script with a specific bot name.
  ./test_client.rb -b botname_bot
- If the script founds the bot, you can start conversation.
- Send "quit" to terminate the conversation.

./test_client.rb -b situationtrack202001_bot


# dialogue extraction

dialogue_extraction.rb

# reference
https://www.rubydoc.info/gems/tdlib-ruby/2.2.0/TD/ClientMethods#get_chat_message_by_date-instance_method
https://www.rubydoc.info/gems/tdlib-ruby/2.2.0/TD/Types/Messages
https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1search_public_chat.html
