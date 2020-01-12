# src/channel_callbacks/main_stress.cr
require "./user"
require "./message"

class ChatRoom
  getter         receive_mesg : Channel(Message), departure_channel : Channel(User)
  private getter users = [] of User, topic : String

  def initialize(@topic)
    @users               = [] of User
    @departure_channel   = Channel(User).new
    @receive_msg_channel = Channel(Message).new
    # puts "CREATED room #{@topic}"
    listen_for_messages
    listen_for_departures
  end

  def join(user : User)
    return self if users.includes? user.email

    @users << user  if user.joined_chat(self, departure_channel)
    # puts "#{user.name} has JOINED room #{topic}"
    self
  end

  def leave(user : User)
    return self unless users.includes? user.email

    @users.delete(user.email)
    # puts "#{user.name} has LEFT room #{topic}"
    self
  end

  def to_s
    topic
  end

  def post_message(message : Message)
    sender = message.sender
    unless users.has_key?(sender.email)
      puts "Rejected Message - you must be a join before sending messages"
      return self
    end

    receiver     = message.receiver
    room_topic   = "#{topic.to_s.upcase} - #{message.to_s.topic}"
    room_message = Message.new( sender: sender, receiver: receiver,
                                text: message.text, topic: room_topic )
    case receiver
    when nil?
      # puts "sending broadcast in #{to_s}"
      spawn send_broadcast(room_message)
    else
      if users.has_key?(receiver.email)
        # puts "sending chat direct to: #{receiver.to_s}"
        spawn send_message(receiver, room_message)
      else
        puts "Rejected - User not currently a Member"
      end
    end
    self
  end

  private def send_broadcast(full_message : Message)
    users.each_value do |receiver|
      send_message(receiver, full_message)
    end
    self
  end

  private def send_message(receiver : User, full_message : Message)
    receiver.channel.send(full_message)
    self
  end

  private def listen_for_messages
    spawn do
      loop do
        message = receive_msg_channel.receive?
        break     if message.nil?

        post_message(message)
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







# make callback status channel
# status = Channel(User).new

# make a large number of users
users  = [] of User
10000.times do |i|
  user = User.new(name: "user_#{i}",
                  email: "user_#{i}@example.ch",
                  status: status)
  users << user
end

# send lots of messages - async (for some reason async needs to be first)
users.each do |receiver|
  spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
  receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
end

# # send lots of messages - async (for some reason async needs to be first)
# users.each do |receiver|
#   spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
# end

# close asynchronously to allow messages to be delivered
users.each do |receiver|
  spawn receiver.channel.close
end

# wait for all channels to close before allowing main to terminate
######
# now we can wait for the right number of status callbacks
(users.size).times { status.receive }

# we can also do this and 'unscribe' users when they close their channels
# while users.size > 0
#   user   = status.receive?
#   break if user.nil?
#
#   users.delete(user)
#   puts "CLOSED: #{user.to_s}"
# end
