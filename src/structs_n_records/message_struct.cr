# src/structs_n_records/message_struct.cr
require "./user"

struct Message
  getter sender : User, receiver : User?, topic : String, text : String

  def initialize(@sender  : User, @text : String, @receiver : User? = nil, @topic : String = "")
    @text = text.strip
    @topic = topic.strip
  end

  def to_s
    output = [] of String
    output << "-" * 30
    output << "From: #{sender.to_s}"
    output << "To: #{receiver.to_s}"  unless receiver.nil?
    output << "Topic: #{topic}"       unless topic == ""
    output << text.strip
    output << "-" * 30
    output.join("\n")
  end
end

user_1 = User.new(name: "user_1", email: "user_1@example.com")
user_2 = User.new(name: "user_2", email: "user_2@example.com")

mesg_1 = Message.new(sender: user_2, text: "Hi")
mesg_2 = Message.new(sender: user_1, text: "Hoi", topic: "Greet")
mesg_3 = Message.new(sender: user_1, text: "Hoi", topic: "Greet", receiver: user_2)

user_1.post_message(mesg_1)
user_2.post_message(mesg_2)
user_2.post_message(mesg_3)
