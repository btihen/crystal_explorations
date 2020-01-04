# src/concurrency/spawn_block.cr
puts "before spawn"
spawn do
  puts "within spawn"
end
puts "after spawn"

Fiber.yield
