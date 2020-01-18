# src/channel_callbacks/main.cr
require "./user"

module Main
  # make callback channel for users
  # notice 'Nil' as a class/constant not a value
  user_closed = Channel(Nil).new

  # make a large number of users
  users  = [] of User

  100.times do |i|
    # all users get given the same channel to notify of closure
    user = User.new(name: "user_#{i}", email: "user_#{i}@example.ch",
                    departure_channel: user_closed)
    users << user
  end

  # send lots of messages - async (for some reason async needs to be first)
  users.each do |receiver|
    receiver.message_channel.send("SYNC 0 -- From: #{receiver.to_s}")
    spawn receiver.message_channel.send("ASYNC 1 -- From: #{receiver.to_s}")
  end

  # channels allow chaining too!
  users.each do |receiver|
    receiver.message_channel.send("SYNC 3 -- From: #{receiver.to_s}")
    spawn receiver.message_channel.send("ASYNC 4 -- From: #{receiver.to_s}")
                                  .send("ASYNC 5 -- close is next")
                                  .close
  end

  puts "LISTEN for CLOSED CHANNELS before closing"
  # listen and wait for all users to close
  (users.size).times { user_closed.receive }
  puts "ALL users CLOSED - safe to end"
end
