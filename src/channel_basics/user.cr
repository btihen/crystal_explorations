# src/channel_basics/user.cr

class User
  getter channel : Channel(String)
  private getter name : String, email : String

  def initialize(@name, @email)
    @channel = Channel(String).new # create a message channel that expects to receive a string
    listen_for_messages            # start listening for new incoming messages
  end

  def to_s
    "#{name} <#{email}>"
  end

  # Creates a Fiber 'loop' waiting for messages to arrive
  # crystal switches fibers after each lap through the loop
  private def listen_for_messages
    spawn do
      loop do
        message = channel.receive? # check for new messages
        break if message.nil?      # skip message processing without a message (which would cause an exception)

        puts "To: #{to_s} -- #{message}"
      end
    end
  end
end
