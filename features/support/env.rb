$LOAD_PATH.unshift 'generated/proto'

require 'grpc-api-assistant'
require 'calculator_services_pb'

include GRPC::Core::StatusCodes