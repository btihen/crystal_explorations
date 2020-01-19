# https://crystal-lang.org/
# A very basic HTTP server
require "http/server"

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response.print "Hello world, got #{context.request.path}!"
end

puts "Listening on http://127.0.0.1:8080"
server.listen(8080)


# # https://forum.crystal-lang.org/t/distinction-between-channels-and-fibers/1190
# require "socket"
#
# def handle_client(client)
#   message = client.gets
#   client.puts message
# end
#
# server = TCPServer.new("localhost", 8080)
# while client = server.accept?
#   spawn handle_client(client)
# end
