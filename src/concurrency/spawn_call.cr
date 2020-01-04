# src/concurrency/spawn_call.cr

i = 0
puts "SYNC: i = 0 = #{i}"         # synchronous
spawn puts "ASYNC: i = 0 = #{i}"  # asynchronous

i = 1
puts "SYNC: i = 1 = #{i}"         # synchronous
spawn puts "ASYNC: i = 1 = #{i}"  # asynchronous

Fiber.yield      # i = 1 when the main thread yields to the fibers!
