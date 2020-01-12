# src/channel_basics/main_stress.cr
require "./user"

module MainStress

  # make a large number of users
  users  = [] of User
  1000.times do |i|
    user = User.new(name: "user_#{i}",  email: "user_#{i}@example.ch")
    users << user
  end

  # both sync and async together doesn't work
  # users.each do |receiver|
  #   # async messaging
  #   spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
  #
  #   # synchronous messaging
  #   receiver.channel.send("SYNC -- From: #{receiver.to_s} - with channel")
  # end

  # send lots of messages - async (for some reason async needs to be first)
  users.each do |receiver|
    spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
  end

  # send lots of messages - sync (for some reason async needs to be first)
  users.each do |receiver|
    receiver.channel.send("SYNC -- From: #{receiver.to_s} - with channel")
  end

  # close user channels
  users.each do |receiver|
    # synchronous channel closing
    # receiver.channel.close

    # close asynchronously to allow messages to be delivered
    spawn receiver.channel.close
  end

  # Allow fibers to execute
  Fiber.yield

  # # wait for all channels to close before allowing main to terminate
  # loop do
  #   break if users.all?{ |u| u.channel.closed? } # are all channels are closed?
  #   Fiber.yield
  # end
end
