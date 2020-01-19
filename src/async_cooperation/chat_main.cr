# src/channel_callbacks/main.cr
require "./chat_user"
require "./chat_room"
require "./chat_message"

module ChatMain
  # make a few chat rooms
  rooms = [] of ChatRoom
  2.times do |i|
    room = ChatRoom.new(topic: "Topic #{i}")
    rooms << room
  end

  # make a large number of users
  users  = [] of User
  30.times do |i|
    user = User.new(name: "user_#{i}", email: "user_#{i}@example.ch")
    users << user

    # signup users to rooms
    rooms.each do |room|
      user.joins(room)
    end
  end
  # close asynchronously 1/3 of users
  users.first(10).each do |user|
    user.message_channel.close
  end

  Fiber.yield

  users.each do |user|
    rooms.each {|room| spawn room.message_channel
                                .send( Message.new(sender: user, text: "ASYNC 0 - from: #{user.to_s} in #{room.to_s}") ) }
  end

  Fiber.yield

  # close asynchronously 1/3 of users
  users.first(3).each do |user|
    spawn user.message_channel.close
  end

  Fiber.yield

  users.each do |user|
    rooms.each {|room| spawn room.message_channel
                                .send( Message.new(sender: user, text: "ASYNC 0 - from: #{user.to_s} in #{room.to_s}") ) }
  end

  # send lots more messages - chat room should only send to users in chat
  users.each do |user|
    room = rooms.shuffle.first
    spawn room.message_channel.send( Message.new(sender: user, text: "from: #{user.to_s} in #{room.to_s}") )
    spawn user.message_channel.close
  end
  #
  # # we can also do this and 'unscribe' users when they close their channels
  loop do
    break if users.all?{ |u| u.message_channel.closed? } # are all channels are closed?
    Fiber.yield
  end

  # while users.size > 0
  #   user   = status.receive?
  #   break if user.nil?
  #
  #   users.delete(user)
  #   puts "CLOSED: #{user.to_s}"
  # end
end
