Before do |scenario|
  @grpc_request = nil
  @grpc_metadata = Hash.new
  @grpc_response = nil
  @stored_templates = Hash.new
  @stored_known_values = Hash.new
end
