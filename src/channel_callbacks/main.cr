# src/channel_callbacks/main.cr
require "./user"

module Main

  # make callback status channel
  user_closed = Channel(User).new

  # make a large number of users
  users  = [] of User

  100.times do |i|
    user = User.new(name: "user_#{i}", email: "user_#{i}@example.ch", departure_channel: user_closed)
    users << user
  end

  # send lots of messages - async (for some reason async needs to be first)
  users.each do |receiver|
    receiver.message_channel.send("SYNC 0 -- From: #{receiver.to_s} - with channel")
    spawn receiver.message_channel.send("ASYNC 1 -- From: #{receiver.to_s} - with channel")
  end

  # channels allow chaining too!
  users.each do |receiver|
    receiver.message_channel.send("SYNC 2 -- From: #{receiver.to_s} - with channel").send("SYNC 3 -- From: #{receiver.to_s} - with channel")
    spawn receiver.message_channel.send("ASYNC 4 -- From: #{receiver.to_s} - with channel").send("ASYNC 5 -- From: #{receiver.to_s} - with channel").close
  end

  # close asynchronously to allow all messages to be delivered and put close at the end of the queue
  # users.each do |receiver|
  #   spawn receiver.message_channel.close
  # end

  # wait for all users to close
  (users.size).times { user_closed.receive }
end
