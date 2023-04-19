require 'time'

Given 'the package prefix is {string}' do |package_prefix|
  @package_prefix = package_prefix
end

Given 'a key called {string} has a known value' do |name|
  @stored_known_values[name] = Helpers.get_env(name) || name + "_" + SecureRandom.uuid
end

Given 'the value {int} is saved in a key called {string}' do |value, name|
  @stored_known_values[name] = value
end

Given 'the value {string} is saved in a key called {string}' do |value, name|
  if value.downcase == "time.now"
    value = Time.now.strftime("%s")
  end

  @stored_known_values[name] = value.gsub("CURRENT_TIME()") { Time.now.utc.iso8601 }
end

Given 'a(n) {string} that looks like the following' do |message_name, json|
  @grpc_request = GrpcHelpers::create_message(@package_prefix + message_name, json, @stored_known_values)
end

Given 'a(n) {string} message template named {string} that looks like' do |message_name, label, json|
  @stored_templates[label] = {
    :message_name => @package_prefix + message_name,
    :template_text => json
  }
end

Given 'the grpc metadata keys and values are set as' do |table|
  table.hashes.each do |row|
    value = GrpcHelpers::instantiate_template(row[:value], @stored_known_values)
    @grpc_metadata[row[:key]] = value
  end
end

Given 'the grpc metadata key {string} has a random value' do |key|
  value = GrpcHelpers::instantiate_template("{RANDOM()}", @stored_known_values)
  @grpc_metadata[key] = value
end

Given('the grpc metadata key {string} is {string}') do |key, value|
  value = GrpcHelpers::instantiate_template(value, @stored_known_values)
  @grpc_metadata[key] = value
end

Given 'an empty string is saved in a key called {string}' do |key|
  @stored_known_values[key] = ""
end

Given 'the value from the key {string} is saved in a key called {string}' do |from_key, to_key|
  @stored_known_values[to_key] = @stored_known_values[from_key]
end

Given 'the value {string} is saved in a stored known values with a key called {string}' do |value, key|
  @stored_known_values[key] = value
end

Given 'I wait {int} millisecond(s)' do |ms|
  sleep(ms / 1000)
end

When 'the value of {string} in the response object is saved in a key called {string}' do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  @stored_known_values[key_name] = value
end

When 'I call the {string} method in the {} service with a(n) {string} that looks like' do |method, service_name, message_name, template|
  @grpc_request = GrpcHelpers::create_message(@package_prefix + message_name, template, @stored_known_values)
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end

When 'I call the {string} method in the {} service' do |method, service_name|
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end

When 'I call the {string} method in the {} service with the message template named {string}' do |method, service_name, template_label|
  expect(@stored_templates.key? template_label).to(be(true), "There is no template named #{template_label}!")
  interesting_template = @stored_templates[template_label]
  # we don't really need to store this, but it might make debugging easier
  @grpc_request = GrpcHelpers::create_message(interesting_template[:message_name], interesting_template[:template_text], @stored_known_values)
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end

Then 'the response object is not an error' do
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
end

Then 'the response gives the error code {int}' do |code|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).to be_a(GRPC::BadStatus)
  expect(@grpc_response.code).to eq(code), "Unexpected error code!  Message: #{@grpc_response.message}"
end

Then 'the response is an error with code {int} and message {string}' do |code, message_template|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).to be_a(GRPC::BadStatus)
  expect(@grpc_response.code).to eq(code), "Unexpected error code!  Message: #{@grpc_response.message}"
  message = GrpcHelpers::instantiate_template(message_template, @stored_known_values)
  expect(@grpc_response.message).to include(message)
end

Then 'the {string} field in the response object has a value' do |field_path|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.nil?).to be false
  expect(value.empty?).to be false if value.respond_to?(:empty?)
end

Then 'the {string} field in the response object has {int} value(s)' do |field_path, count|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.kind_of?(Google::Protobuf::RepeatedField) || value.is_a?(Array)).to be_truthy, "expected an Array, got a #{value.class}"
  expect(value.size).to eq count.to_i
end

Then 'the {string} field in the response object has a recent millisecond timestamp' do |field_path|
  step "the '#{field_path}' field in the response object has a timestamp less than 5000 milliseconds old"
end

Then 'the {string} field in the response object has a timestamp less than {int} millisecond(s) old' do |field_path, ms|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).to be_within(ms).of(Time.now.to_f * 1000)
end

Then 'the {string} field in the response object has a timestamp at least {int} millisecond(s) old' do |field_path, ms|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).not_to be_within(ms).of(Time.now.to_f * 1000)
end

Then 'the {string} field in the response object has a timestamp less than {int} second(s) old' do |field_path, seconds|
  step "the '#{field_path}' field in the response object has a timestamp less than #{seconds * 1000} milliseconds old"
end

Then 'the {string} field in the response object has a timestamp at least {int} second(s) old' do |field_path, seconds|
  step "the '#{field_path}' field in the response object has a timestamp at least #{seconds * 1000} milliseconds old"
end

Then(/^the '(.+)' field in the response object has a timestamp equal to '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)'$/) do |field_path, timestamp|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers.fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.seconds).to eq Time.parse(timestamp).to_i
end

Then(/^the '(.+)' field in the response object has a timestamp equal to 'nil'$/) do |field_path|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers.fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).to be nil
end

Then 'the {string} field in the response object is less than {int}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f).to be < expected_value
end

Then 'the {string} field in the response object is greater than {int}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f).to be > expected_value
end

Then 'the {string} field in the response object is {int}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f).to eq expected_value
end

Then 'the {string} field in the response object is {string}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to eq expected_value
end

Then 'the {string} field in the response object is not {int}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f).not_to eq expected_value
end

Then 'the {string} field in the response object is not {string}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).not_to eq expected_value
end

Then 'the {string} field in the response object is {boolean}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).to eq expected_value
end

Then 'the {string} field in the response object contains the substring {string}' do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to include expected_value
end

Then 'the {string} field in the response object matches {Set} as a set' do |field_path, expected_set|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  actual_set = value.to_set
  expect(actual_set).to eq expected_set
end

Then 'the {string} field in the response object has a value in the list {StringList}' do |field_path, keys|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  # The key_name is a comma-delineated string holding an array of field names for the passage request.
  # We can split on commas due to commas being illegal characters for Lucene and Elasticsearch field names.
  # array = key_name.split(",")
  expect(keys).to include(value)
end

Then 'the {string} response object looks like' do |message_name, template|
  expected = GrpcHelpers::create_message(@package_prefix + message_name, template, @stored_known_values)
  expect(@grpc_response).to eq(expected)
end

Then 'the response stream of {string} looks like' do |message_name, template|
  expected_array = GrpcHelpers::create_array(@package_prefix + message_name, template, @stored_known_values)
  expect(@grpc_response).to match_array(expected_array)
end

Then 'the {string} field in the response object is empty' do |field_path|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.empty?).to be true if value.respond_to?(:empty?)
  expect(value.size).to eq 0 if value.respond_to?(:size)
end

Then 'the {string} field in the response object is the same as the value stored in the key {string}' do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to eq @stored_known_values[key_name].to_s
end

Then 'the {string} field in the response object is not the same as the value stored in the key {string}' do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers.fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to_not eq @stored_known_values[key_name].to_s
end

Then 'the response stream has {int} message(s)' do |count|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response.size).to eq count.to_i
end
