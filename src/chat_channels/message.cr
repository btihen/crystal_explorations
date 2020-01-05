# src/chat_channels/message.cr
require "./user"

struct Message
  getter( sender : User,  text : String,
          topic : String, receiver : User? )

  def initialize(@sender, @text, @topic="", @receiver=nil)
    @text  = text.strip
    @topic = topic.strip
  end

  def to_s
    output = [] of String
    output << "-" * 30
    output << "From: #{sender.to_s}"
    output << "To: #{receiver.to_s}" if receiver.present?
    output << "Topic: #{topic}"      if topic != ""
    output << "Mesg: #{text}"
    output << "-" * 30
    output.join("\n")
  end
end
