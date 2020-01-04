# src/concurrency/spawn_proc_block.cr

i = 0
puts_0 = ->(x : Int32) do
  spawn do
    puts(x)
  end
end
puts_0.call(i)

i = 1
puts_1 = ->(x : Int32) do
  spawn do
    puts(x)
  end
end
puts_1.call(i)

Fiber.yield
