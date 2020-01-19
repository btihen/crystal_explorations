require “kemal”
# https://medium.com/@zenitram.oiram/a-beginners-guide-to-websockets-in-elm-and-crystal-8f510c28eb61
# https://github.com/martimatix/crystal-elm-chat
SOCKETS = [] of HTTP::WebSocket

ws “/chat” do |socket|
  # Add the client to SOCKETS list
  SOCKETS << socket

  # Broadcast each message to all clients
  socket.on_message do |message|
    SOCKETS.each { |socket| socket.send message}
  end

  # Remove clients from the list when it’s closed
  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
