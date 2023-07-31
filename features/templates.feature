Feature: Templates and Variables

  It's often useful to be able to substitute request values between scenarios,
  fore example, when only part of a request is interesting for a particular
  feature.

  To support this, the gem includes a templating system that does basic string
  substitutions.  Additionally, specific or random values can be stored in
  variables that can be used in requests and when checking values.  Variables
  are referenced in templates by wrapping the variable name in brackets,
  {some_variable}.

  If you don't care what the value is and just need something random,
  use "given a key called 'x' has a known value".  This will generate a random
  value for the key or, if an environment variable with the same name as the
  key is present, that value will be used instead.

  Scenario: Call method with metadata and confirm metadata has been received
    Given the package prefix is 'Calculator::'
    And a key called 'foo' has a known value
    And a 'UnaryRequest' message template named 'the request' that looks like
      """
      {
      "x": {number},
      "operand": "{operand}"
      }
      """
    And the grpc metadata keys and values are set as
      | key    | value |
      | random | {foo} |
    Given the value '5' is saved in a key called 'number'
    And the value '-' is saved in a key called 'operand'
    When I call the 'unary_operation' method in the Calculator service with the message template named 'the request'
    Then the 'result' field in the response object is -5
    And the value '-5' is saved in a key called 'expected'
    And the 'result' field in the response object is the same as the value stored in the key 'expected'
    And the value '123456' is saved in a key called 'not expected'
    And the 'result' field in the response object is not the same as the value stored in the key 'not expected'

  Scenario: Substitute values in template variables
    Given the value '{RANDOM()}' is saved in a key called 'random guid'
    And the value '{CURRENT_TIME()}' is saved in a key called 'current time'
    And the value 'any data' is saved in a key called 'anything'
    And the value '{anything}' is saved in a key called 'copy of anything'
    And the value 'time.now' is saved in a key called 'now'
    Then the value stored in the key 'random guid' is a GUID-shaped value
    And the value stored in the key 'current time' is close to the current time
    And the value stored in the key 'anything' is 'any data'
    And the value stored in the key 'copy of anything' is 'any data'
    And the value stored in the key 'now' is close to the current time
