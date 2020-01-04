# src/concurrency/spawn_block.cr
puts "before spawn"   # synchronous
spawn do
  puts "within spawn" # asynchronous
end
puts "after spawn"    # synchronous

Fiber.yield
