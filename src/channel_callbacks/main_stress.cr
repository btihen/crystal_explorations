# src/channel_callbacks/main_stress.cr
require "./user"

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

  # send lots of messages - async (for some reason async needs to be first)
  users.each do |receiver|
    spawn receiver.channel.send("ASYNC -- From: #{receiver.to_s} - with channel")
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
  while users.size > 0
    user   = status.receive?
    break if user.nil?

    users.delete(user)
    puts "CLOSED: #{user.to_s}"
  end
end
