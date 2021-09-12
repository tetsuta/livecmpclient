#!/usr/local/bin/ruby
# coding: utf-8
require_relative './config'


# coding: utf-8
require_relative './client'

# ==================================================
class Dialogue_History
  def initialize(td_message_list, my_user_id)
    @message_list = []
    @my_user_id = my_user_id

    td_message_list.reverse().each{|td_message|
      message = Dialogue_Message.new(td_message, @my_user_id)
      if message.is_start?
        @message_list.clear()
      end
      @message_list.push(message)
    }
  end


  def size()
    return @message_list.size
  end


  def each_message()
    @message_list.each{|message|
      yield(message)
    }
  end


  def to_s
    buffer = ""
    self.each_message{|message|
      buffer << message.to_s
      buffer << "\n"
    }
    return buffer
  end

end

# ==================================================
class Dialogue_Message
  attr_reader :sender_id, :text
  def initialize(td_message, my_user_id)
    @my_user_id = my_user_id
    @sender_id = td_message.sender.user_id
    @text = td_message.content.text.text
  end


  def is_start?
    if @text =~ /^\/start/
      return true
    else
      return false
    end
  end

  def to_s
    buffer = ""
    if @sender_id == @my_user_id
      sender_flag = "U"
    else
      sender_flag = "S"
    end

    buffer << "#{sender_flag}: #{text}"
    
    return buffer
  end

end


# ==================================================
class Telegram_Fetch
  def initialize(tdllib_path, api_id, api_hash, cache_time)
    @telegram = Simple_TD.new(tdllib_path, api_id, api_hash)
    @number_of_message = 35
    @cache_time = cache_time
    @last_load_time = nil
    @dialogue_history = nil
  end


  def select_chat(bot_name)
    @telegram.select_chat(bot_name)
  end


  def load_history()
    now = Time.now
    if @last_load_time == nil || (now - @last_load_time) > @cache_time
      # puts "RELOAD!!!"
      if @telegram.ready_to_talk?
        td_message_list = @telegram.get_recent_messages(@number_of_message)
        @last_load_time = Time.now()
        @dialogue_history = Dialogue_History.new(td_message_list, @telegram.my_user_id())
      else
        STDERR.puts "Telegram server isn't ready"
        return nil
      end
    else
      # puts "Cache!!!"
      # cache can work
    end

    return @dialogue_history
  end


  def close()
    @telegram.close()
  end
end


bot_name = "situationtrack202001_bot"
telegram_fetch = Telegram_Fetch.new(TDLIB_PATH, API_ID, API_HASH, Dialogue_History_Cache_Time)
telegram_fetch.select_chat(bot_name)

puts "1st"
history = telegram_fetch.load_history()
puts history.to_s
sleep 2

puts "2 sec"
history = telegram_fetch.load_history()
puts history.to_s
sleep 7

puts "7 sec"
history = telegram_fetch.load_history()
puts history.to_s


telegram_fetch.close()

