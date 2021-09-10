#!/usr/local/bin/ruby
# coding: utf-8

require 'tdlib-ruby'
require './localconfig'

TD.configure do |config|
  config.lib_path = '/usr/local/lib'

  config.client.api_id = API_ID
  config.client.api_hash = API_HASH
end

TD::Api.set_log_verbosity_level(1)

client = TD::Client.new

begin
  state = nil

  client.on(TD::Types::Update::AuthorizationState) do |update|
    # puts "0000000000"
    # p update.to_json
    # puts "0000000000"

    state = case update.authorization_state
            when TD::Types::AuthorizationState::WaitPhoneNumber
              :wait_phone_number
            when TD::Types::AuthorizationState::WaitCode
              :wait_code
            when TD::Types::AuthorizationState::WaitPassword
              :wait_password
            when TD::Types::AuthorizationState::Ready
              :ready
            else
              nil
            end
  end
  
  client.connect

  loop do
    case state
    when :wait_phone_number
      puts 'Please, enter your phone number:'
      phone = STDIN.gets.strip
      client.set_authentication_phone_number(phone_number: phone, settings: nil).wait
    when :wait_code
      puts 'Please, enter code from SMS:'
      code = STDIN.gets.strip
      client.check_authentication_code(code: code).wait
    when :wait_password
      puts 'Please, enter 2FA password:'
      password = STDIN.gets.strip
      client.check_authentication_password(password: password).wait
    when :ready
      client.get_me.then { |user| @me = user }.rescue { |err| puts "error: #{err}" }.wait

      puts "11111111111111111111111111"
      # bot_name = "situationtrack202001_bot"
      # # puts bot_name
      # # # ret = client.search_chats(query: bot_name, limit: 10)  # <-- need to wait to get value
      # ret = client.search_chats(query: bot_name, limit: 10).value
      # puts ret.class
      # p ret

      bot_name = "situationtrack202001_bot"
      puts bot_name
      chat = client.search_public_chat(username: bot_name).value
      if chat.class == TD::Types::Chat
        puts "yes"
        puts chat.id
      else
        puts "no"
      end
      puts "rrrr"
      puts chat.class
      p chat

      ### send message
      # message_text = "/start"
      # message_text = "おはよう"
      # message = TD::Types::InputMessageContent::Text.new(text: TD::Types::FormattedText.new(text: message_text, entities: []),
      #                                                    disable_web_page_preview: true,
      #                                                    clear_draft: false)
      # client.send_message(chat_id: chat.id,
      #                     message_thread_id: nil,
      #                     reply_to_message_id: nil,
      #                     options: nil,
      #                     reply_markup: nil,
      #                     input_message_content: message).wait


      ### recieve message
      received_message = client.get_chat_message_by_date(chat_id: chat.id,
                                                         date: Time.now.to_i).value
      puts "nnnn"
      p received_message
      puts received_message.class
      puts received_message.content.text.text

      break
    end
    sleep 0.1
  end

ensure
  client.dispose
end


puts @me.class
puts "---"
p @me

