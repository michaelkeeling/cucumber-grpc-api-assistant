module GrpcApiAssistant
  module ServiceManager
    extend self

    class Services
      def self.instance
        @__instance__ ||= new
      end

      def initialize
        @services = Hash.new
      end

      def add_service(service_name, service_double)
        if @services.key? service_name
          raise "already added a service by this name #{service_name}"
        end

        @services[service_name] = Object.const_get(service_double).new
        @services[service_name]
      end

      def get_service(service_name)
        unless @services.key? service_name
          raise "the stored services does not have the key #{service_name}"
        end

        @services[service_name]
      end

      def get_services
        @services
      end

      def remove_service(service_name)
        @services.delete service_name
      end

      def remove_all_services
        @services.clear
      end
    end

    def services
      if block_given?
        yield Services.instance
      else
        Services.instance
      end
    end

  end
end
