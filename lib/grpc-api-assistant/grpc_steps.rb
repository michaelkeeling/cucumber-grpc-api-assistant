Given /^the package prefix is '(.+)'$/ do |package_prefix|
  @package_prefix = package_prefix
end

Given /^a key called '(.+)' has a known value$/ do |name|
  @stored_known_values[name] = Helpers.get_env(name) || name + "_" + SecureRandom.uuid
end

Given /^the value '(.+)' is saved in a key called '(.+)'$/ do |value, name|
  if value.downcase == "time.now"
    value = Time.now.strftime("%s")
  end

  @stored_known_values[name] = value
end

Given /^(\d+) times the value (-?\d+) is saved in a key called '(.+)'$/ do |multiplier, value, key_name|
  step "the value '#{value.to_i * multiplier.to_i}' is saved in a key called '#{key_name}'"
end

Given /^an? '(.+)' that looks like the following$/ do |message_name, json|
  @grpc_request = GrpcHelpers::create_message(@package_prefix + message_name, json, @stored_known_values)
end

Given /^an? '(.+)' message template named '(.+)' that looks like$/ do |message_name, label, json|
  @stored_templates[label] = {
      :message_name => @package_prefix + message_name,
      :template_text => json
  }
end


Given /^the grpc metadata keys and values are set as$/ do |table|
  table.hashes.each do |row|
    @grpc_metadata[row[:key]] = row[:value]
  end
end

Given /^an empty string is saved in a key called '(.+)'$/ do |key|
  @stored_known_values[key] = ""
end

Given /^the value from the key '(.+)' is saved in a key called '(.+)'$/ do |from_key, to_key|
  @stored_known_values[to_key] = @stored_known_values[from_key]
end

Given /^the value '(.+)' is saved in a stored known values with a key called '(.+)'$/ do |value, key|
  @stored_known_values[key] = value
end

When /^the value of '(.+)' in the response object is saved in a key called '(.+)'$/ do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  step "the value '#{value}' is saved in a stored known values with a key called '#{key_name}'"
end


When /^I call the '(.+)' method in the (.+) service with an? '(.+)' that looks like$/ do |method, service_name, message_name, template|
  @grpc_request = GrpcHelpers::create_message(@package_prefix + message_name, template, @stored_known_values)
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end


When /^I call the '(.+)' method in the (.+) service$/ do |method, service_name|
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end


When /^I call the '(.+)' method in the (.+) service with the message template named '(.+)'$/ do |method, service_name, template_label|
  expect(@stored_templates.key? template_label).to(be(true), "There is no template named #{template_label}!")
  interesting_template = @stored_templates[template_label]
  # we don't really need to store this, but it might make debugging easier
  @grpc_request = GrpcHelpers::create_message(interesting_template[:message_name], interesting_template[:template_text], @stored_known_values)
  @grpc_response = GrpcHelpers::call(GrpcApiAssistant::ClientManager.clients.get_client(service_name), method, @grpc_request, @grpc_metadata)
end

Then /^the response object is not an error$/ do
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
end

Then /^the response gives the error code '(.+)'$/ do |code|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).to be_a(GRPC::BadStatus)
  expect(@grpc_response.code).to eq(code.to_i), "Unexpected error code!  Message: #{@grpc_response.message}"
end

Then /^the response is an error with code '(.+)' and message '(.+)'$/ do |code, message_template|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).to be_a(GRPC::BadStatus)
  expect(@grpc_response.code).to eq(code.to_i), "Unexpected error code!  Message: #{@grpc_response.message}"
  message = GrpcHelpers::instantiate_template(message_template, @stored_known_values)
  expect(@grpc_response.message).to eq(message)
end

Then /^the '(.+)' field in the response object has a value$/ do |field_path|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.nil?).to be false
  expect(value.empty?).to be false if value.respond_to?(:empty?)
end


Then /^the '(.+)' field in the response object has (\d+) values?$/ do |field_path, count|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.kind_of?(Google::Protobuf::RepeatedField) || value.is_a?(Array)).to be_truthy, "expected an Array, got a #{value.class}"
  expect(value.size).to eq count.to_i
end


Then /^the '(.+)' field in the response object has a recent millisecond timestamp$/ do |field_path|
  step "the '#{field_path}' field in the response object has a timestamp less than 5000 milliseconds old"
end


Then /^the '(.+)' field in the response object has a timestamp less than (\d+) milliseconds old$/ do |field_path, ms|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response).not_to be_a(GRPC::BadStatus)
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).to be_within(ms.to_i).of(Time.now.to_i * 1000)
end


Then /^the '(.+)' field in the response object is less than '(\d+)'$/ do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f < expected_value.to_f).to be true
end


Then /^the '(.+)' field in the response object is greater than '(\d+)'$/ do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_f > expected_value.to_f).to be true
end


Then /^the '(.+)' field in the response object is '(.+)'$/ do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to eq expected_value
end


Then /^the '(.+)' field in the response object is not '(.+)'$/ do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).not_to eq expected_value
end


Then /^the '(.+)' field in the response object contains the substring '(.+)'$/ do |field_path, expected_value|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to include expected_value
end


Then /^the '(.+)' field in the response object matches '(.+)' as a set$/ do |field_path, list|
  expect(@grpc_response).not_to be nil
  expected_set = JSON.parse(list).to_set

  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  actual_set = value.to_set
  expect(actual_set).to eq expected_set
end


Then /^the '(.+)' field in the response object has a value in the list '(.+)'$/ do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  # The key_name is a comma-delineated string holding an array of field names for the passage request.
  # We can split on commas due to commas being illegal characters for Lucene and Elasticsearch field names.
  array = key_name.split(",")
  expect(array).to include(value)
end


Then /^the '(.+)' response object looks like$/ do |message_name, template|
  expected = GrpcHelpers::create_message(@package_prefix + message_name, template, @stored_known_values)
  expect(@grpc_response).to eq(expected)
end


Then /^the response stream of '(.+)' looks like$/ do |message_name, template|
  expected_array = GrpcHelpers::create_array(@package_prefix + message_name, template, @stored_known_values)
  expect(@grpc_response).to match_array(expected_array)
end


Then /^the '(.+)' field in the response object is empty$/ do |field_path|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.empty?).to be true if value.respond_to?(:empty?)
end


Then /^the '(.+)' field in the response object is the same as the value stored in the key '(.+)'$/ do |field_path, key_name|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value.to_s).to eq @stored_known_values[key_name]
end


Then /^the response stream has (\d+) messages?$/ do |count|
  expect(@grpc_response).not_to be nil
  expect(@grpc_response.size).to eq count.to_i
end


Then /^the '(.+)' field in the response object is true$/ do |field_path|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).to be
end


Then /^the '(.+)' field in the response object is false$/ do |field_path|
  expect(@grpc_response).not_to be nil
  value = GrpcHelpers::fetch_from_grpc_with_shorthand(field_path, @grpc_response)
  expect(value).not_to be
end
