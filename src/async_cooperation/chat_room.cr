# src/channel_callbacks/main_stress.cr
require "./chat_user"
require "./chat_message"

class ChatRoom
  getter  message_channel : Channel(Message), departure_channel : Channel(User)

  private getter users = [] of User, topic : String

  def initialize(@topic)
    @users             = [] of User
    @departure_channel = Channel(User).new(9)     # call back channel to depart
    @message_channel   = Channel(Message).new(9)  # message channel for forwarding
    # puts "CREATED room #{@topic}"
    listen_for_messages
    listen_for_departures
  end

  def to_s
    topic
  end

  def join(user : User)
    return self if users.includes? user

    @users << user
    puts "#{user.to_s} has JOINED room #{to_s}"
    self
  end

  private def leave(user : User)
    return self unless users.includes? user

    @users.delete(user)
    puts "#{user.to_s} has LEFT room #{to_s}"
    self
  end

  private def forward_message(message : Message)
    sender = message.sender
    unless users.includes?(sender)
      puts "Rejected Message from #{sender.to_s} - join room #{to_s} first"
      return self
    end

    receiver     = message.receiver
    room_topic   = "#{topic.to_s.upcase}"
    room_topic  += " - #{message.topic.to_s.strip}" unless message.topic.nil?
    room_message = Message.new( sender: sender, receiver: receiver,
                                text: message.text, topic: room_topic )
    if receiver.nil?
      # puts "sending broadcast in #{to_s}"
      spawn send_broadcast(room_message)
    elsif users.includes?(receiver)
      # puts "sending chat direct to: #{receiver.to_s}"
      spawn send_message(receiver, room_message)
    else
      puts "Rejected - User not currently a Member"
    end
    self
  end

  private def send_broadcast(message : Message)
    users.each do |receiver|
      send_message(receiver, message)
    end
    self
  end

  private def send_message(receiver : User, message : Message)
    receiver.message_channel.send(message)  unless receiver.message_channel.closed?
    self
  end

  private def listen_for_messages
    spawn do
      loop do
        message = message_channel.receive?
        break     if message.nil?

        forward_message(message)
      end
    end
  end

  private def listen_for_departures
    spawn do
      loop do
        user = departure_channel.receive?
        break  if user.nil?

        leave(user)
      end
    end
  end

end
