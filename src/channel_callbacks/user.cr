# src/channels_buffered/user.cr

class User
  getter         message_channel : Channel(String)

  private getter name, email, departure_channel

  def initialize(@name : String, @email : String, @departure_channel : Channel(User))
    @message_channel = Channel(String).new(3)
    listen_for_messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  private def listen_for_messages
    spawn do
      loop do
        message = message_channel.receive?
        break     if message.nil?

        puts "To: #{to_s} -- #{message}"
      end
      puts "#{to_s} -- CLOSING"
      # notify main when done
      departure_channel.send(self)
    end
  end
end
