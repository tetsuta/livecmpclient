# coding: utf-8
require_relative './client'
require 'json'

# ==================================================
class Dialogue_History
  attr_reader :message_list
  def initialize(td_message_list, my_user_id)
    @message_list = []
    @my_user_id = my_user_id

    td_message_list.reverse().each{|td_message|
      message = Dialogue_Message.new(td_message.sender.user_id, td_message.content.text.text, @my_user_id)
      if message.is_start?
        @message_list.clear()
      end
      @message_list.push(message)
    }
  end

  # for stab
  def load(content)
    data = JSON.parse(content)
    @my_user_id = data["my_user_id"]
    data["message_list"].each{|message_hash|
      message = Dialogue_Message.new(message_hash["sender_id"], message_hash["text"], message_hash["my_user_id"])
      @message_list.push(message)
    }
  end

  # for stab
  def dump()
    data = Hash::new()
    data["message_list"] = []
    data["my_user_id"] = @my_user_id
    each_message{|message|
      data["message_list"].push(message.make_hash)
    }
    return JSON.generate(data)
  end


  def size
    return @message_list.size
  end


  def each_message
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


  def to_html
    buffer = ""
    index = 1
    buffer << "<table class=\"table table-striped table-bordered\">\n"

    buffer << "<tr><th>発話者</th><th>評価ID</th><th>発話</th></tr>"

    finished = false
    self.each_message{|message|
      next if message.is_start?
      next if finished
      if message.text =~ /_FINISHED_/
        finished = true
      end

      buffer << message.to_html(index)
      buffer << "\n"

      if message.is_system?
        index += 1
      end
    }
    buffer << "</table>\n"
    return buffer
  end


  def to_html2
    buffer = ""
    index = 1
    buffer << "<hr>\n"
    buffer << "<div style=\"background-color: #7897C5;\">"
    self.each_message{|message|
      buffer << message.to_html2(index)
      buffer << "\n"
      if message.is_system?
        index += 1
      end
    }
    buffer << "</div>"
    return buffer
  end

end

# ==================================================
class Dialogue_Message
  attr_reader :sender_id, :text
  def initialize(sender_id, text, my_user_id)
    @my_user_id = my_user_id
    @sender_id = sender_id
    @text = text
  end


  def is_start?
    if @text =~ /^\/start/
      return true
    else
      return false
    end
  end


  # for stab
  def make_hash
    data = Hash::new()
    data["my_user_id"] = @my_user_id
    data["sender_id"] = @sender_id
    data["text"] = @text
    return data
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


  def is_system?
    if @sender_id == @my_user_id
      return false
    else
      return true
    end
  end


  def to_html(index)
    buffer = ""
    buffer << "<tr>"
    if self.is_system?
      sender_flag = "S"
      eval_id = index.to_s
    else
      sender_flag = "U"
      eval_id = ""
    end

    buffer << "<td>#{sender_flag}</td>"
    buffer << "<td>#{eval_id}</td>"
    if self.is_system? && text !~ /_FINISHED_/ && text !~ /messages.html/
      buffer << "<td class=\"systemUtt\" eid=\"#{eval_id}\">#{text}</td>"
    else
      buffer << "<td>#{text}</td>"
    end
    buffer << "</tr>"
    return buffer
  end


  def to_html2(index)
    buffer = ""
    if self.is_system?
      eval_id = index.to_s
      if text !~ /_FINISHED_/ && text !~ /messages.html/
        buffer << "<p class=\"left_balloon systemUtt\" eid=\"#{eval_id}\">#{eval_id}: #{text}</p>"
      else
        buffer << "<p class=\"left_balloon\">#{eval_id}: #{text}</p>"
      end
    else
      buffer << "<p class=\"right_balloon\">#{text}</p>"
    end
    return buffer
  end

end


# ==================================================
class Telegram_Fetch
  # if stab_file is specified, it use stab_file instead of fetching from server
  def initialize(tdllib_path, api_id, api_hash, cache_time, stab_file = nil)
    quiet = true
    @telegram = Simple_TD.new(tdllib_path, api_id, api_hash, quiet)
    @number_of_message = 35
    @cache_time = cache_time
    @stab_file = stab_file
    @stab_content = nil
    @last_load_time = nil
    @dialogue_history = nil

    if @stab_file != nil && FileTest::exist?(@stab_file)
      File.open(@stab_file){|fp|
        @stab_content = fp.read()
      }
    end
  end


  def select_chat(bot_name)
    @telegram.select_chat(bot_name)
  end


  def load_history()
    if @stab_file != nil && @stab_content != nil
      dialogue_history = Dialogue_History.new([], nil)
      dialogue_history.load(@stab_content)

      if dialogue_history.message_list.size > 0
        STDERR.puts "file cache!!!"
        @dialogue_history = dialogue_history
        return @dialogue_history
      end
    end

    now = Time.now
    if @last_load_time == nil || (now - @last_load_time) > @cache_time
      STDERR.puts "td_fetch_server.rb: RELOAD!!!"
      if @telegram.ready_to_talk?
        td_message_list = @telegram.get_recent_messages(@number_of_message)
        @last_load_time = Time.now()
        @dialogue_history = Dialogue_History.new(td_message_list, @telegram.my_user_id())
      else
        STDERR.puts "Telegram server isn't ready"
        return nil
      end
    else
      STDERR.puts "td_fetch_server.rb: Cache!!!"
      # cache can work
    end

    if @stab_file != nil
      STDERR.puts "store file cache!!!"
      File.open(@stab_file, "w"){|wfp|
        wfp.puts @dialogue_history.dump
      }
    end

    return @dialogue_history
  end


  def close()
    STDERR.puts("Closing...")
    @telegram.close()
    STDERR.puts("Done")
  end
end


