# src/channel_callbacks/main.cr

require "./user"

# create users
status = Channel(User).new
user_1 = User.new(name: "first",  email: "first@example.ch", status: status)
user_2 = User.new(name: "second", email: "second@example.ch", status: status)

puts "REAL-TIME - START"
spawn user_1.channel.send("ASYNC sent 1st!")
user_1.channel.send("REAL-TIME sent 2nd!")
spawn user_1.channel.send("ASYNC sent 3th!")
user_2.channel.send("REAL-TIME sent 4th!")
spawn user_2.channel.send("ASYNC sent 5th!")
user_1.channel.send("REAL-TIME sent 6th!")
puts "REAL-TIME - DONE"
user_1.channel.close
user_2.channel.close

2.times { status.receive }
