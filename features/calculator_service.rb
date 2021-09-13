class CalculatorService < Calculator::Calculator::Service
  def unary_operation(service_request, _call)
    @received_metadata = _call.metadata
    case service_request.operand
      when "+"
        result = service_request.x * 1
      when "-"
        result = service_request.x * -1
      else
        raise GRPC::BadStatus.new_status_exception(code = UNIMPLEMENTED, details = 'operand not implemented')
    end

    Calculator::UnaryResponse.new(x: service_request.x,
                                  operand: service_request.operand,
                                  result: result.to_s)
  end


  def multi_unary_operation(service_request, _call)
    @received_metadata = _call.metadata

    case service_request.operand
      when "+"
        results = service_request.xs.collect { |x| (x * 1).to_s }
      when "-"
        results = service_request.xs.collect { |x| (x * -1).to_s }
      else
        raise GRPC::BadStatus.new_status_exception(code = UNIMPLEMENTED, details = 'operand not implemented')
    end

    # a = Google::Protobuf::RepeatedField.new(:string, results)

    Calculator::MultiUnaryResponse.new(xs: service_request.xs.to_a,
                                       operand: service_request.operand,
                                       results: results)
  end


  def binary_operation(service_request, _call)
    @received_metadata = _call.metadata

    case service_request.operand
      when "+"
        result = service_request.x + service_request.y
      when "-"
        result = service_request.x - service_request.y
      when "=="
        bool_result = service_request.x == service_request.y
      else
        raise GRPC::BadStatus.new_status_exception(code = UNIMPLEMENTED, details = 'operand not implemented')
    end

    Calculator::BinaryResponse.new(x: service_request.x,
                                   y: service_request.y,
                                   operand: service_request.operand,
                                   result: result.to_s,
                                   boolean_result: bool_result)
  end


  def range(service_request, _call)
    @received_metadata = _call.metadata
    Range.new(service_request.s, service_request.e).obtain_range.each
  end


  def current_time(request, _call)
    @received_metadata = _call.metadata
    Calculator::Timestamp.new(ms: 1000 * Time.now.to_i)
  end


  def get_metadata(key)
    @received_metadata[key]
  end

  def get_all_metadata
    @received_metadata
  end


  class Range
    def initialize(s, e)
      @s = s
      @e = e
      @enumerable = []
    end
    def obtain_range
      (@s..@e).each do |i|
        @enumerable.push(Calculator::RangeResponse.new(x: i, numeric_result: i, boolean_result: i % 2 == 1))
      end
      @enumerable
    end
  end

end
