# src/concurrency/spawn_block_unexpected.cr

i = 0
spawn do
  puts i
end

i = 1
spawn do
  puts i
end

Fiber.yield
