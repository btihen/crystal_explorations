# src/channels_buffered/user.cr

class User
  getter         mesg_channel : Channel(String)
  private getter name, email, notify_departures

  def initialize(@name : String, @email : String, @notify_departures = {} of String => Channel(User))
    @mesg_channel = Channel(String).new(2)
    @notify_departures = [] of Channel(User)
    listen_for_messages
  end

  def joined_chat?(room : ChatRoom, leave_room_channel : Channel(User))  # actually need notifier
    @notify_departures[room.to_s] = leave_room_channel
    true
  end

  def to_s
    "#{name} <#{email}>"
  end

  private def listen_for_messages
    spawn do
      loop do
        message = mesg_channel.receive?
        break     if message.nil?

        puts "To: #{to_s} -- #{message}"
      end
      puts "#{to_s} -- CLOSING"
      # notify each room when closed to messages
      notify_departures.each |leave_room_channel|
        leave_room_channel.send(self)
      end
    end
  end
end
