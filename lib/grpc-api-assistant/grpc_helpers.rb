require 'grpc-api-assistant/test_logger'

module GrpcHelpers
  LOGGER = GrpcApiAssistant::TestLogger

  def self.create_message(message_name, template, template_values)
    json = self.instantiate_template(template, template_values)
    LOGGER.debug json
    Object::const_get(message_name).decode_json(json)
  end

  def self.create_array(message_name, array_json, template_values)
    json = self.instantiate_template(array_json, template_values)
    array = JSON.parse(json, symbolize_names: true)
    array.map { |hash| Object::const_get(message_name).decode_json(JSON.generate(hash)) }
  end

  def self.call(client, method, request, metadata)
    metadata = {:metadata => metadata}
    response = client.method(method.to_sym).call(request, metadata)
    LOGGER.debug response
    response.respond_to?(:to_a) ? response.to_a : response
  rescue => error
    error
  end

  def self.fetch_from_grpc_with_shorthand(field_path, message)
    fields = field_path.split("/")
    value = message
    fields.each do |f|
      f = f.to_i if f.to_i.to_s == f

      if !(value.is_a? String)
        value = value[f] if value.respond_to?(:[])
      else
        value = JSON.parse(value)
        value = value[f] if value.respond_to?(:[])
      end
    end
    value
  end

  def self.instantiate_template(template, known_values)
    result = template.gsub("{RANDOM()}") { SecureRandom.uuid }
    known_values.each {|k, v| result = result.gsub("{" + k + "}", v.to_s)}
    result
  end

end
