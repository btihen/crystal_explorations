# src/simple_channels/main_stress.cr
require "./user"

module MainStress

  # make a large number of users
  users  = [] of User
  status = Channel(Nil).new
  10000.times do |i|
    user = User.new(name: "user_#{i}",  email: "user_#{i}@example.ch")
    users << user
  end

  # send lots of messages
  users.each do |receiver|
    # async messaging
    spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")

    # synchronous messaging
    # receiver.channel.send("SYNC -- From: #{receiver.to_s} - with channel")
  end

  # close user channels
  # users.each do |receiver|
  #   # synchronous channel closing
  #   # receiver.channel.close
  #
  #   # close asynchronously to allow messages to be delivered
  #   spawn receiver.channel.close
  # end

  # Allow fibers to execute
  Fiber.yield

  # wait for all channels to close before allowing main to terminate
  # loop do
  #   break if users.all?{ |u| u.channel.closed? } # are all channels are closed?
  #   Fiber.yield
  # end
end
