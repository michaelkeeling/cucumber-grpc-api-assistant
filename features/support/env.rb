# frozen_string_literal: true

$LOAD_PATH.unshift 'generated/proto'

require 'grpc-api-assistant'
require 'calculator_services_pb'

require 'pry'
require 'pry-byebug'

include GRPC::Core::StatusCodes
