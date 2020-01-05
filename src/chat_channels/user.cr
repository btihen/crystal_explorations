# src/chat_channels/user.cr
require "./message"

class User

  getter user_channel : Channel(String)
  private getter name : String, email : String, signoff_msg : Channel(User)

  def initialize(@name, @email, @status)
    @user_channel = Channel(String).new
    listen_for_user_messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  def post_message(text)
    puts "To: #{to_s} -- #{text}"
  end

  def send_user_msg(receiver : User, text : String, topic : String = "")
    room.room_channel.send(room_msg)
  end

  def send_room_msg(room : Room, text : String, topic : String = "", receiver : User? = nil)
    room_msg = Message.new( sender: self, receiver: receiver,
                            text: message.text, topic: topic_w_room )
    room.room_channel.send(room_msg)
  end

  private def listen_for_user_messages
    spawn do
      loop do
        user_text = user_channel.receive?
        break    if user_text.nil?

        post_message(user_text)
      end
      puts "#{to_s} -- CLOSING"
      signoff_msg.send(self)   # loop ends when channels closes - send close status
    end
  end

end
