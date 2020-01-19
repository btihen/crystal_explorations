# simplify and get working

require "socket"
require "http/web_socket"
require "http/server"

VTX_SERVER_ADDR="locahost"

module VTXClientServerCrystal
  VERSION = "0.1.0"
  class VTXClientServerCrystal
    @listen_port : Int32
    def initialize
      ENV["LISTEN_PORT"] ||= "7003"
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
      context = OpenSSL::SSL::Context::Server.new
      context.certificate_chain = "./cert/server.cert"
      context.private_key = "./cert/server.key"
      address = server.bind_tls Socket::IPAddress.new("127.0.0.1", @listen_port), context
      server.listen
    end
  end

  server = VTXClientServerCrystal.new
  server.route_connections
end
