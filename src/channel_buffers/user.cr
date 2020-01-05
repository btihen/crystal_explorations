# src/channels_buffered/user.cr

class User
  getter channel : Channel(String)
  private getter name : String, email : String, status : Channel(User)

  def initialize(@name, @email, @status)
    @channel = Channel(String).new(3)
    listen_for_messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  private def listen_for_messages
    spawn do
      loop do
        message = channel.receive?
        break     if message.nil?

        puts "To: #{to_s} -- #{message}"
      end
      puts "#{to_s} -- CLOSING"
      status.send(self)   # loop ends when channels closes - send close status
    end
  end
end
