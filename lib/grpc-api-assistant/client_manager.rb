module GrpcApiAssistant
  module ClientManager
    extend self

    class Clients
      def self.instance
        @__instance__ ||= new
      end

      def initialize
        @grpc_clients = Hash.new
      end

      # TODO: add an insecure client version too
      def add_client(service_name, package_name, host, port, service_endpoint=nil, cred=nil, chan=nil)
        raise "A client for the service, #{service_name}, already exists!" if @grpc_clients.key? service_name

        service_endpoint = "#{host}:#{port}" if service_endpoint.nil?

        if !cred.nil? && !chan.nil?
          channel_args = {GRPC::Core::Channel::SSL_TARGET => chan}
          opts = Hash.new
          opts[:channel_args] = channel_args

          @grpc_clients[service_name] = Object.const_get(package_name)::Stub.new(
            service_endpoint,
            GRPC::Core::ChannelCredentials.new(File.read(cred)),
            **opts
          )
        else
          @grpc_clients[service_name] =
            Object.const_get(package_name)::Stub.new(service_endpoint, :this_channel_is_insecure)
        end
      end

      def get_client(service_name)
        if !@grpc_clients.key? service_name
          raise "No client for the given service: #{service_name}"
        end

        @grpc_clients[service_name]
      end

      def get_clients
        @grpc_clients
      end

      def remove_client(service_name)
        @grpc_clients.delete(service_name)
      end

      def remove_all_clients
        @grpc_clients.clear
      end
    end

    def clients
      if block_given?
        yield Clients.instance
      else
        Clients.instance
      end
    end
  end
end
