# src/chat_channels/listener.cr

module Listener
  def listen_for_messages
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
