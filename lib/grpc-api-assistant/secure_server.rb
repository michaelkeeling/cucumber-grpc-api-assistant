require 'net/ssh'

module GrpcApiAssistant
  class SecureServer

    @@all_doubles = []
    LOGGER = GrpcApiAssistant::TestLogger

    def initialize(host, port, password, server_cert, ca_cert, pem, *services)
      @host = host
      @port = port
      @services = services
      @password = password
      @server_cert = server_cert
      @ca_cert = ca_cert
      @pem = pem
    end

    def set_services(*services)
      @services = services
    end


    def start
      @server = GRPC::RpcServer.new
      endpoint = "#{@host}:#{@port}"

      pass = @password
      key = Net::SSH::KeyFactory.load_private_key(@pem, pass).to_s
      cert = File.read(@server_cert)

      credentials = GRPC::Core::ServerCredentials.new(
          File.read(@ca_cert),
          [{
               private_key: key,
               cert_chain: cert
           }],
          false
      )

      @server.add_http2_port(endpoint, credentials)

      LOGGER.info("MockGrpcServer running securely on #{endpoint}")

      @services.each {|s| @server.handle(s)}
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
