# src/channel_basics/main_close_wait.cr
require "./user"

module MainCloseWait

  # make a large number of users
  users  = [] of User
  1000.times do |i|
    user = User.new(name: "user_#{i}",  email: "user_#{i}@example.ch")
    users << user
  end

  # send lots of messages - async (for some reason async needs to be first)
  users.each do |receiver|
    spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
  end

  # close user channels
  users.each do |receiver|
    # synchronous channel closing
    # receiver.channel.close

    # close asynchronously to allow messages to be delivered
    spawn receiver.channel.close
  end

  # wait for all channels to close before allowing main to terminate
  # Fiber.yield

  loop do
    break if users.all?{ |u| u.channel.closed? } # are all channels are closed?
    Fiber.yield
  end
end
