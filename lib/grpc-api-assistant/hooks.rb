# frozen_string_literal: true

Before do |_scenario|
  @grpc_request = nil
  @grpc_metadata = {}
  @grpc_response = nil
  @stored_templates = {}

  # Reset the @stored_konwn_values and load substitition "functions" used in templates
  @stored_known_values = {
    'RANDOM()' => -> { SecureRandom.uuid },
    'CURRENT_TIME()' => -> { Time.now.utc }
  }
end
