Feature: Basic gRPC step functions

  This feature will be used to provide generic service testing
  for the grpc-api-assistant gem.

  Background:
    Given the package prefix is 'Calculator::'


  Scenario: Call method and check the field values of the return object
    Given an 'UnaryRequest' that looks like the following
    """
    {
      "x": 6,
      "operand": "-"
    }
    """
    And 2 times the value -3 is saved in a key called 'saved_value'
    When I call the 'unary_operation' method in the Calculator service
    Then the response object is not an error
    And the 'result' field in the response object has a value
    And the 'result' field in the response object is '-6'
    And the 'result' field in the response object is the same as the value stored in the key 'saved_value'
    And the 'result' field in the response object contains the substring '-'
    And the 'result' field in the response object is less than '0'
    And the 'result' field in the response object has a value in the list '5,-6'


  Scenario: Call method using a template
    Given a 'BinaryRequest' message template named 'binary' that looks like
    """
    {
      "x": 2,
      "y": 3,
      "operand": "{+}"
    }
    """
    And I call the 'binary_operation' method in the Calculator service with the message template named 'binary'
    Then the value of 'result' in the response object is saved in a key called 'result_value'
    And the 'result' field in the response object is the same as the value stored in the key 'result_value'


  Scenario: Returns an UNIMPLEMENTED error
    Given I call the 'binary_operation' method in the Calculator service with an 'BinaryRequest' that looks like
    """
    {
      "x": 2,
      "y": 3,
      "operand": "%"
    }
    """
    Then the response is an error with code '12' and message '12:operand not implemented'


  Scenario: Call a method and obtain a response object that contains a boolean and empty value
    Given I call the 'binary_operation' method in the Calculator service with an 'BinaryRequest' that looks like
    """
    {
      "x": 2,
      "y": 3,
      "operand": "=="
    }
    """
    Then the 'BinaryResponse' response object looks like
    """
      {
        "x": 2,
        "y": 3,
        "operand": "==",
        "result": "",
        "boolean_result": false
      }
    """
    And the 'boolean_result' field in the response object is false
    And the 'result' field in the response object is empty


  Scenario: Demonstrate the usage of streams
    Given I call the 'range' method in the Calculator service with an 'RangeRequest' that looks like
    """
    {
      "s": 1,
      "e": 5
    }
    """
    Then the response stream has 5 messages
    And the response stream of 'RangeResponse' looks like
    """
    [
      {"x": 1, "numeric_result": 1, "boolean_result": true},
      {"x": 2, "numeric_result": 2, "boolean_result": false},
      {"x": 3, "numeric_result": 3, "boolean_result": true},
      {"x": 4, "numeric_result": 4, "boolean_result": false},
      {"x": 5, "numeric_result": 5, "boolean_result": true}
    ]
    """


  Scenario: Demonstrate simple time comparison step definitions
    Given I call the 'current_time' method in the Calculator service with an 'Empty' that looks like
    """
    """
    Then the 'ms' field in the response object has a recent millisecond timestamp
    And the 'ms' field in the response object has a timestamp less than 500 milliseconds old


  Scenario: Call method with metadata and confirm metadata has been received
    Given an 'UnaryRequest' that looks like the following
    """
    {
      "x": 1,
      "operand": "-"
    }
    """
    And the grpc metadata keys and values are set as
      | key           | value        |
      | some_key      | key_number_1 |
      | another_key   | key_number_2 |
    When I call the 'unary_operation' method in the Calculator service
    Then the response object is not an error
    And the Calculator Testing Service receives metadata
      | key           | value       |
      | some_key      | key_number_1 |
      | another_key   | key_number_2 |


  Scenario: Call method and check the field values of the return object
    Given an 'MultiUnaryRequest' that looks like the following
    """
    {
      "xs": ["1","3","5"],
      "operand": "-"
    }
    """
    When I call the 'multi_unary_operation' method in the Calculator service
    Then the response object is not an error
    And the 'results' field in the response object has 3 values
    And the 'results' field in the response object matches '["-1", "-5", "-3"]' as a set
    And the 'results/0' field in the response object is '-1'
    And the 'results/0' field in the response object is not '1000'
