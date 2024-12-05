# frozen_string_literal: true

Given 'I remove the client with name {string}' do |client_name|
  GrpcApiAssistant::ClientManager.clients.remove_client(client_name)
end

Given 'I clear the clients' do
  GrpcApiAssistant::ClientManager.clients.remove_all_clients
end

Given 'I remove the service with name {string}' do |service_name|
  GrpcApiAssistant::ServiceManager.services.remove_service(service_name)
end

Given 'I clear the services' do
  GrpcApiAssistant::ServiceManager.services.remove_all_services
end

Given 'I remove the server with name {string}' do |server_name|
  GrpcApiAssistant::ServerManager.servers.remove_server(server_name)
end

Given 'I clear the servers' do
  GrpcApiAssistant::ServerManager.servers.remove_all_servers
end

Given 'I reset the server {string} with service {string}' do |server_name, service_name|
  GrpcApiAssistant::ServerManager.servers.reset_server(server_name, service_name)
end

When 'I add the service {string} with name {string}' do |service, service_name|
  GrpcApiAssistant::ServiceManager.services.add_service(service_name, service)
end

When 'I add a client with name {string}, package name {string}, host {string}, port {int}, service_endpoint {string}, cred {string}, and channel {string}' \
do |service_name, package_name, host, port, service_endpoint, cred, chan|
  GrpcApiAssistant::ClientManager.clients.add_client(service_name, package_name, host, port, service_endpoint, cred,
                                                     chan)
end

When 'I add a client with name {string}, package name {string}, host {string}, port {int}' do |service_name, package_name, host, port|
  GrpcApiAssistant::ClientManager.clients.add_client(service_name, package_name, host, port)
end

Then 'there are no clients stored' do
  expect(GrpcApiAssistant::ClientManager.clients.get_clients.empty?).to be true
end

Then 'the client with name {string} is stored in the clients' do |client_name|
  expect(GrpcApiAssistant::ClientManager.clients.get_client(client_name)).not_to be nil
end

Then 'the client with name {string} is not stored in the clients' do |client_name|
  expect(GrpcApiAssistant::ClientManager.clients.get_client(client_name))
# This method in ClientUtils module throws an error if the 'client'
# is not stored and there is an attempt to retrieve the client.
rescue StandardError => e
  expect(e.to_s).to eq("No client for the given service: #{client_name}")
else
  expect(true).to be false
end

Then 'there is 1 client stored' do |_count|
  step 'there are 1 clients stored'
end

Then 'there are {int} client(s) stored' do |count|
  expect(GrpcApiAssistant::ClientManager.clients.get_clients.length).to be count.to_i
end

Then 'there are no services stored' do
  expect(GrpcApiAssistant::ServiceManager.services.get_services.empty?).to be true
end

Then 'the service with name {string} is stored in services' do |service_name|
  expect(GrpcApiAssistant::ServiceManager.services.get_service(service_name)).not_to be nil
end

Then 'the service with name {string} is not stored in the services' do |service_name|
  expect(GrpcApiAssistant::ServiceManager.services.get_service(service_name))
# This method in ClientUtils module throws an error if the 'service'
# is not stored and there is an attempt to retrieve the service.
rescue StandardError => e
  expect(e.to_s).to eq("the stored services does not have the key #{service_name}")
else
  expect(true).to be false
end

Then 'there is 1 service stored' do |_count|
  step 'there are 1 services stored'
end

Then 'there are {int} service(s) stored' do |count|
  expect(GrpcApiAssistant::ServiceManager.services.get_services.length.to_i).to be count.to_i
end

Then 'the server with name {string} is stored in server' do |server_name|
  expect(GrpcApiAssistant::ServerManager.servers.get_server(server_name)).not_to be nil
end

Then 'the server with name {string} is not stored in the servers' do |server_name|
  expect(GrpcApiAssistant::ServerManager.servers.get_server(server_name))
# This method in ClientUtils module throws an error if the 'server'
# is not stored and there is an attempt to retrieve the server.
rescue StandardError => e
  expect(e.to_s).to eq("the stored servers does not have the key #{server_name}")
else
  expect(true).to be false
end

Then 'there is 1 server stored' do
  step 'there are 1 servers stored'
end

Then 'there are {int} server(s) stored' do |count|
  expect(GrpcApiAssistant::ServerManager.servers.get_servers.length.to_i).to be count.to_i
end

Then 'there are no servers stored' do
  expect(GrpcApiAssistant::ServerManager.servers.get_servers.empty?).to be true
end
