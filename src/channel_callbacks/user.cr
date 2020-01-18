# src/channels_buffered/user.cr

class User
  getter         message_channel : Channel(String)

  private getter name, email, departure_channel

  # notice 'Nil' as a class/constant not a value in the Definition
  def initialize(@name : String, @email : String, @departure_channel : Channel(Nil))
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
      puts "#{to_s} -- CLOSED"
      # notify when loop ends -- channel is closed
      # notice 'nil' as the value when sending
      departure_channel.send(nil)
    end
  end
end
