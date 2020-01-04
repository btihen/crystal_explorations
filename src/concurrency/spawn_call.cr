# src/concurrency/spawn_call.cr

i = 0
puts i

i = 1
puts i

Fiber.yield
