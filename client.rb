#!/usr/local/bin/ruby
# coding: utf-8

require 'tdlib-ruby'
require './localconfig'

class Simple_TD
  def initialize(tdllib_path, api_id, api_hash, quiet = false)
    @quiet = quiet
    configure(tdllib_path, api_id, api_hash)
    TD::Api.set_log_verbosity_level(1)

    @me = nil
    @chat = nil
    @client = TD::Client.new
    connect_server()
  end


  def close()
    @client.dispose
  end


  def log_message(message)
    unless @quiet
      STDOUT.puts message
    end
  end


  def ready_to_talk?
    if @chat != nil
      log_message("Ready")
      return true
    else
      log_message("Not ready")
      return false
    end
  end


  def showme()
    p @me
  end


  def select_chat(bot_name)
    @chat = @client.search_public_chat(username: bot_name).value
    if @chat.class == TD::Types::Chat
      log_message("Found #{bot_name} / #{@chat.id}")
    else
      log_message("Not found #{bot_name}")
    end
  end


  def get_message()
    received_message = @client.get_chat_message_by_date(chat_id: @chat.id,
                                                       date: Time.now.to_i).value
    if received_message == nil
      return nil
    else
      return received_message.content.text.text
    end
  end


  def send_message(message_text)
    message = TD::Types::InputMessageContent::Text.new(text: TD::Types::FormattedText.new(text: message_text, entities: []),
                                                       disable_web_page_preview: true,
                                                       clear_draft: false)
    @client.send_message(chat_id: @chat.id,
                         message_thread_id: nil,
                         reply_to_message_id: nil,
                         options: nil,
                         reply_markup: nil,
                         input_message_content: message).wait
  end


  private

  def configure(tdlib_path, api_id, api_hash)
    TD.configure do |config|
      config.lib_path = tdlib_path
      config.client.api_id = api_id
      config.client.api_hash = api_hash
    end
  end


  def connect_server()
    state = nil
    @client.on(TD::Types::Update::AuthorizationState) do |update|
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
    @client.connect
    loop do
      case state
      when :wait_phone_number
        puts 'Please, enter your phone number:'
        phone = STDIN.gets.strip
        @client.set_authentication_phone_number(phone_number: phone, settings: nil).wait
      when :wait_code
        puts 'Please, enter code from SMS:'
        code = STDIN.gets.strip
        @client.check_authentication_code(code: code).wait
      when :wait_password
        puts 'Please, enter 2FA password:'
        password = STDIN.gets.strip
        @client.check_authentication_password(password: password).wait
      when :ready
        @client.get_me.then { |user| @me = user }.rescue { |err| puts "error: #{err}" }.wait
        break
      end
      sleep 0.1
    end

  end

end



telegram = Simple_TD.new(TDLIB_PATH, API_ID, API_HASH)

bot_name = "situationtrack202001_bot"
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
      sleep 5
      puts telegram.get_message()
    end
  end
end

telegram.close()

