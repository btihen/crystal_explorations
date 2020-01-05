require "./user"
require "./room"

module ChatChannels
  VERSION = "0.1.0"


  # two named users for light testing
  user_1 = User.new(name: "first",  email: "first@noise.ch")
  user_2 = User.new(name: "second", email: "second@noise.ch")

  # # test that users can send direct messages to each other's channels directly
  # user_1.channel.send( Message.new(sender: user_2, receiver: user_1, text: "Hi there!") )
  # user_2.channel.send( Message.new(sender: user_1, receiver: user_2, text: "Howdy!") )
  #
  # puts "#" * 60

  # # use the user api
  # user_1.send_message(receiver: user_2, text: "Hi API #2")
  # user_1.send_message(receiver: user_1, text: "No Loop")
  # user_2.send_message(receiver: user_1, text: "Enjoy channels")

  # create a chat room
  chat = Room.new(topic: "noise")

  # # first two joing chat
  chat.join(user_1)
  chat.join(user_2)
  # chat.join(user_2)  # should have no effect
  #
  # puts "%" * 55
  # # light messaging tests in message board
  # user_1.send_message(room: chat, text: "Cool Stuff")
  # # user_2.send_message(room: chat, text: "Enjoy These", topic: "Channels")
  #
  #
  # puts "%" * 55
  # Fiber.yield   # stop until messages delivered
  #
  # puts "%" * 55
  #
  # # leave chat
  # chat.leave(user_1)
  # user_1.send_message(room: chat, text: "Not Seen - already left group")
  # Fiber.yield
  # chat.leave(user_2)
  # chat.leave(user_2)  # should have no effect

  puts "#" * 60
  #
  # stress testing
  users  = [] of User
  100000.times do |i|
    user_i = User.new(name: "user_#{i}", email: "user_#{i}@noise.ch")
    chat.join(user_i)
  end

  user_1.send_message(room: chat, receiver: user_2, text: "Direct two you")
  user_1.send_message(room: chat, text: "Cool Stuff")
  # have each user send a message to the group
  # users.each do |user|
  #   user.send_message(room: chat, text: "#{user.to_s} to all")
  # end

  # let spawned fibers / channels run
  Fiber.yield
  #
  sleep 4  # let all the channels finish before disconnecting abruptly

  # users.each do |user|
  #   # chat.leave(user)
  #   spawn chat.leave(user)
  # end
  # Fiber.yield

end
