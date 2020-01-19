# get working

require "http/web_socket"

uri    = URI.parse("ws://localhost:3000")
socket = HTTP::WebSocket.new(uri)  
socket.send "Howdy1"

socket.on_message do |message|
  puts message
end

socket.send "Howdy2"

socket.run

socket.send "Howdy2"