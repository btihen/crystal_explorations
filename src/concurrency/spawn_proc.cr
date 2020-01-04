# src/concurrency/spawn_proc.cr

i = 0
puts "SYNC: i = 0 = #{i}"       # synchronous
proc_0 = ->(x : Int32) do
  spawn do
    puts "ASYNC: i = 0 = #{x}"  # asynchronous
  end
end
proc_0.call(i)

i = 1
puts "SYNC: i = 1 = #{i}"       # synchronous
proc_1 = ->(x : Int32) do
  spawn do
    puts "ASYNC: i = 1 = #{x}"  # asynchronous
  end
end
proc_1.call(i)

Fiber.yield
