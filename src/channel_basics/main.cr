# src/channel_basics/main.cr

require "./user"

# USAGE
module Main
  # create users
  user_1 = User.new(name: "first",  email: "first@example.ch")
  user_2 = User.new(name: "second", email: "second@example.ch")

  # send messages
  puts "REAL-TIME - START"

  # send an async message
  spawn user_1.channel.send("ASYNC sent 1st")

  # send a synchronous message
  user_1.channel.send("REAL-TIME sent 2nd")
  user_1.channel.send("REAL-TIME sent 3rd")

  puts "SWITCH to user_2"
  spawn user_2.channel.send("ASYNC sent 4th")
  user_2.channel.send("REAL-TIME sent 5th")

  puts "SWITCH back to user_1"
  user_1.channel.send("REAL-TIME sent 6th")
  spawn user_1.channel.send("ASYNC sent 7th")
  puts "REAL-TIME - DONE"

  # Allow Fibers (async messages) to execute
  Fiber.yield
end
