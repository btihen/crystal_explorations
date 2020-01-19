# @thedracle (jason thomas)

require "socket"
require "http/web_socket"
require "http/server"

VTX_SERVER_ADDR="127.0.0.1"

module VTXClientServerCrystal
  VERSION = "0.1.0"
  class VTXClientServerCrystal
    @listen_port : Int32
    def initialize
      ENV["LISTEN_PORT"] ||= "8080"
      @listen_port = ENV["LISTEN_PORT"].to_i
    end
    def route_connections
      ws_handler = HTTP::WebSocketHandler.new {|client|
        client.on_message {|next_message|
          puts next_message
          client.send next_message
        };
      };
      server = HTTP::Server.new([ws_handler]);
      # context = OpenSSL::SSL::Context::Server.new
      # context.certificate_chain = "./cert/server.cert"
      # context.private_key = "./cert/server.key"
      # address = server.bind_tls Socket::IPAddress.new("127.0.0.1", @listen_port) # , context
      # HTTP::Server#bind(socket : Socket::Server)
      address = server.bind Socket::IPAddress.new("127.0.0.1", @listen_port) # , context
      server.listen
    end
  end

  server = VTXClientServerCrystal.new
  server.route_connections
end

# # https://medium.com/@muhammadtriwibowo/simple-websocket-using-crystal-13b6f67eba61
#
# # # require "http/server"
# require "http/web_socket"
# # SOCKETS = [] of HTTP::WebSocket
# #
# # ws_server = HTTP::WebSocketHandler.new do |socket|
# #   puts "Socket opened"
# #   SOCKETS << socket
# #
# #   socket.on_message do |message|
# #     SOCKETS.each { |socket| socket.send "Echo back from server: #{message}" }
# #   end
# #
# #   socket.on_close do
# #     SOCKETS.delete(socket)
# #     puts "Socket closed"
# #   end
# # end
#
# # server = HTTP::Server.new([ws_handler])
# # address = server.bind_tcp "localhost", 3000
# # address = server.bind_tcp "0.0.0.0", 3000
# ws_server = HTTP::WebSocket.new(URI.parse("http://127.0.0.1:8080/chat")) do |socket|
#   puts "Socket opened"
#   SOCKETS << socket
#
#   socket.on_message do |message|
#     SOCKETS.each { |socket| socket.send "Echo back from server: #{message}" }
#   end
#
#   socket.on_close do
#     SOCKETS.delete(socket)
#     puts "Socket closed"
#   end
# end
# puts "Listening on http://127.0.0.1:8080/chat"
# ws_server.listen(8080)
#
# # # https://crystal-lang.org/
# # # A very basic HTTP server
# # require "http/server"
# #
# # server = HTTP::Server.new do |context|
# #   context.response.content_type = "text/plain"
# #   context.response.print "Hello world, got #{context.request.path}!"
# # end
# #
# # puts "Listening on http://127.0.0.1:8080"
# # server.listen(8080)
