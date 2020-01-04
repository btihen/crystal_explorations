# src/concurrency/user.cr

class User
  getter channel : Channel(String)
  private getter name : String, email : String

  def initialize(@name, @email)
    @channel = Channel(String).new
  end

  def to_s
    "#{name} <#{email}>"
  end

  def post_message(message : String)
    puts "To: #{to_s} -- #{message}"
  end
end
