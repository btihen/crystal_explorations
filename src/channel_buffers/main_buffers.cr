# src/channels_buffered/main_buffers.cr
# require "./user"

class User
  getter  channel : Channel(String)
  private getter name : String, email : String

  def initialize(@name, @email)
    @channel = Channel(String).new(3)  # buffered - can hold 3 messages
    # @channel = Channel(String).new       # unbuffered - holds 1 message
    listen_for_messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  private def listen_for_messages
    spawn do
      loop do
        message = channel.receive?
        break     if message.nil?

        puts "To: #{to_s} -- #{message}"
      end
    end
  end
end

module MainBuffers

  # make a large number of users
  users  = [] of User
  1000.times do |i|
    user = User.new(name: "user_#{i}",  email: "user_#{i}@example.ch")
    users << user
  end

  # sending many sync and async ensures more messages than secondary fibers can handle without a buffer
  users.each do |receiver|
    # synchronous messaging
    receiver.channel.send("SYNC 0 -- From: #{receiver.to_s} - with channel")
    # # synchronous messaging
    # spawn receiver.channel.send("SYNC 2 -- From: #{receiver.to_s} - with channel")
  end

  # sending many sync and async ensures more messages than secondary fibers can handle without a buffer
  users.each do |receiver|
    # async messaging
    spawn receiver.channel.send("ASYNC 3 -- From: #{receiver.to_s} - with channel")
  end

  # close user channels
  users.each do |receiver|
    # close asynchronously to allow messages to be delivered
    spawn receiver.channel.close
  end

  # wait for all channels to close before allowing main to terminate
  loop do
    break if users.all?{ |u| u.channel.closed? } # are all channels are closed?
    Fiber.yield
  end
end
