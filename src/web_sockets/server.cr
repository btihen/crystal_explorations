require "http/server"

# track the open websockets
SOCKETS = [] of HTTP::WebSocket

ws_handler = HTTP::WebSocketHandler.new do |socket|
  puts "Socket opened"
  SOCKETS << socket

  # A very simple chat room indeed
  socket.on_message do |message|
    puts message
    SOCKETS.each { |socket| socket.send message }
  end

  # Clean up any references
  socket.on_close do
    SOCKETS.delete(socket)
  end

  # `.run` is called on the WebSocket automatically when this block returns
end

server = HTTP::Server.new([ws_handler])

address = server.bind_tcp "localhost", 3000
puts "Listening on ws://#{address}"
server.listen