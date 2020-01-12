# src/channel_callbacks/message=.cr
require "./user"

record(Message, sender : User,          text : String,
                receiver : User? = nil, topic : String? = nil) do
  def to_s
    output = [] of String
    output << "-" * 30
    output << "From: #{sender.to_s}"
    output << "To: #{receiver.to_s}"       unless receiver.nil?
    output << "Topic: #{topic.to_s.strip}" unless topic.nil?
    output << text.strip
    output << "-" * 30
    output.join("\n")
  end
end
