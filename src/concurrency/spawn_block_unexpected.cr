# src/concurrency/spawn_block_unexpected.cr

i = 0
puts "SYNC: i = 0 = #{i}"     # synchronous
spawn do
  puts "ASYNC: i = 0 = #{i}"  # asynchronous
end

i = 1
puts "SYNC: i = 1 = #{i}"     # synchronous
spawn do
  puts "ASYNC: i = 1 = #{i}"  # asynchronous
end

Fiber.yield  # i = 1 when the main thread yields to the fibers!
