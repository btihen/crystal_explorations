# src/chat_channels/room.cr
require "./user"
require "./message"

class Room

  getter room_msgs : Channel(Message)
  private getter( topic : String, users = [] of User )

  def initialize(@topic="default")
    @users = [] of User
    @room_msgs = Channel(Message).new
    puts "CREATED room #{topic}"
    listen_for_room_messages
  end

  def to_s
    topic
  end

  def join(user : User)
    return self    if users.includes? user

    @users << user
    puts "#{user.to_s} has JOINED room #{topic}"
    self
  end

  def leave(user : User)
    return self unless users.includes? user

    @users.delete(user)
    puts "#{user.to_s} has LEFT room #{topic}"
    self
  end

  def post_message(message : Message)
    sender = message.sender
    puts "Rejected Message" unless users.includes? sender
    return self             unless users.includes? sender

    receiver     = message.receiver
    topic_w_room = "#{topic.upcase} #{message.topic}"
    text_message = Message.new( sender: sender, receiver: receiver,
                                text: message.text, topic: topic_w_room ).to_s
    case receiver
    when nil?
      puts "sending broadcast in #{to_s}"
      spawn send_broadcast(text_message)
    else
      puts "sending chat direct to: #{receiver.to_s}"
      spawn send_message(receiver, text_message) if users.includes? receiver
    end
    self
  end

  private def send_broadcast(full_message : String)
    users.each_value do |receiver|
      send_message(receiver, text_message)
    end
    self
  end

  private def send_message(receiver : User, text_message : String)
    receiver.channel.send(text_message)
    self
  end

  def listen_for_room_messages
    spawn do
      loop do
        message = room_msgs.receive?
        break     if message.nil?

        post_message(message)
      end
      puts "#{to_s} -- CLOSING"
      # room_status.send(self)   # useful if rooms need to unregister from users
    end
  end

  def listen_for_user_signouts
    spawn do
      loop do
        message = room_msgs.receive?
        break     if message.nil?

        post_message(message)
      end
      puts "#{to_s} -- CLOSING"
      # room_status.send(self)   # useful if rooms need to unregister from users
    end
  end

end
