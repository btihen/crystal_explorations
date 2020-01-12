# src/channels_buffered/main_stress.cr
require "./user"

class ChatRoom
  getter channel : Channel(Message)
  private getter( topic : String, users = {} of String => User )

  def initialize(@topic="default")
    @users = {} of String => User
    @channel = Channel(Message).new
    # puts "CREATED room #{@topic}"
    listen_for_messages
  end

  def join(user : User)
    return self if users.has_key? user.email

    @users[user.email] = user
    # puts "#{user.name} has JOINED room #{topic}"
    self
  end

  def leave(user : User)
    return self unless users.has_key? user.email

    @users.delete(user.email)
    # puts "#{user.name} has LEFT room #{topic}"
    self
  end

  def to_s
    topic
  end

  def post_message(message : Message)
    sender = message.sender
    puts "Rejected Message" unless users.has_key?(sender.email)
    return self             unless users.has_key?(sender.email)

    receiver     = message.receiver
    topic_w_room = "#{topic.upcase} - #{message.topic}"
    room_message = Message.new( sender: sender, receiver: receiver,
                                text: message.text, topic: topic_w_room )
    case receiver
    when nil?
      # puts "sending broadcast in #{to_s}"
      spawn send_broadcast(room_message)
    else
      # puts "sending chat direct to: #{receiver.to_s}"
      spawn send_message(receiver, room_message) if users.has_key?(receiver.email)
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
end

module MainStress

  # make callback status channel
  status = Channel(User).new

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
  users.each do |receiver|
    spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
    receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
  end

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
end
