Before do |scenario|
  calculator_service = GrpcApiAssistant::ServiceManager.services.add_service(
    "Calculator",       # The name you plan to use to reference the service from within test steps
    "CalculatorService" # This is the name of the generated gRPC service
  )

  # calculator_server = GrpcApiAssistant::SecureServer.new(
  #     "0.0.0.0",
  #     12345,
  #     Helpers.get_env("PRIVATE_KEY_PASSPHRASE"),
  #     "server.crt",
  #     "ca.crt",
  #     "server.pem",
  #     *calculator_service
  # )

  calculator_server = GrpcApiAssistant::InsecureServer.new(
    "0.0.0.0",
    12345,
    *calculator_service
  )

  GrpcApiAssistant::ServerManager.servers.add_server(
    "calculator_server", # A name you will use to reference this server from within test steps
    calculator_server    # The GrpcApiAssistant::Server or SecureServer
  )

  calculator_server.start

  # create a secure client
  # GrpcApiAssistant::ClientManager.clients.add_client(
  #     "Calculator",
  #     "::Calculator::Calculator",
  #     "localhost",
  #     12345,
  #     nil,
  #     "server.crt",
  #     "CHANNEL_NAME"
  # )

  GrpcApiAssistant::ClientManager.clients.add_client(
      "Calculator",
      "::Calculator::Calculator",
      "localhost",
      12345
  )

end

Before('@no_server_services_clients') do
  GrpcApiAssistant::ClientManager.clients.remove_all_clients
  GrpcApiAssistant::ServiceManager.services.remove_all_services
  # GrpcApiAssistant::SecureServer.stop_all
  GrpcApiAssistant::InsecureServer.stop_all
end

After do |scenario|
  GrpcApiAssistant::ClientManager.clients.remove_all_clients
  GrpcApiAssistant::ServiceManager.services.remove_all_services
  GrpcApiAssistant::ServerManager.servers.remove_all_servers
  # GrpcApiAssistant::SecureServer.stop_all
  GrpcApiAssistant::InsecureServer.stop_all
end
