module GrpcApiAssistant
  module ServerManager
    extend self

    class Servers
      def self.instance
        @__instance__ ||= new
      end

      def initialize
        @servers = {}
      end

      def add_server(server_name, server)
        raise "already added a server by this name #{server_name}" if @servers.key? server_name

        @servers[server_name] = server
      end

      def get_server(server_name)
        raise "the stored servers does not have the key #{server_name}" unless @servers.key?(server_name)

        @servers[server_name]
      end

      def get_servers
        @servers
      end

      def remove_server(server_name)
        @servers.delete(server_name)
      end

      def remove_all_servers
        @servers.clear
      end

      def reset_server(server_name, service_name)
        server = @servers[server_name]
        server.stop
        server.set_services(ServiceManager.services.get_service(service_name))
        server.start
      end
    end

    def servers
      if block_given?
        yield Servers.instance
      else
        Servers.instance
      end
    end
  end
end
