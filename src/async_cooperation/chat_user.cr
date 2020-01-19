# src/channels_buffered/user.cr
require "./chat_room"
require "./chat_message"

class User

  getter         message_channel : Channel(Message)

  private getter name, email, chat_rooms

  def initialize(@name : String, @email : String)
    @message_channel = Channel(Message).new(3)
    @chat_rooms      = [] of ChatRoom
    listen_for_messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  # track whom to notify
  def joins(room : ChatRoom)
    room.join(self)
    @chat_rooms << room
    self
  end

  private def listen_for_messages
    spawn do

      loop do
        message = message_channel.receive?
        break     if message.nil?

        puts message.to_s
      end

      # notify each room when closed to messages
      puts "#{to_s} -- CLOSED"
      chat_rooms.each do |room|
        room.departure_channel.send(self)
      end

    end
  end

end
