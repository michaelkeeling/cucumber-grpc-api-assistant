require 'net/ssh'

module GrpcApiAssistant
  class InsecureServer

    @@all_doubles = []
    LOGGER = GrpcApiAssistant::TestLogger

    def initialize(host, port, *services)
      @host = host
      @port = port
      @services = services
    end

    def set_services(*services)
      @services = services
    end

    def start
      @server = GRPC::RpcServer.new
      endpoint = "#{@host}:#{@port}"

      @server.add_http2_port(endpoint, :this_port_is_insecure)

      LOGGER.info("MockGrpcServer running INSECURELY on #{endpoint}")

      @services.each { |s| @server.handle(s) }
      @mythread = Thread.new { @server.run_till_terminated }
      @server.wait_till_running(timeout=1)

      @@all_doubles << self
    end

    def stop
      @server.stop if @server and @server.running?
      @mythread.kill if @mythread
      @@all_doubles.delete(self)
    end

    def self.stop_service(name)
    end

    def self.stop_all
      @@all_doubles.compact.each {|m| m.stop}
      @@all_doubles = []
    end
  end
end
