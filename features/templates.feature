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

  Background:
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

  Scenario: Call method with metadata and confirm metadata has been received
    Given the value '5' is saved in a key called 'number'
    And the value '-' is saved in a key called 'operand'
    When I call the 'unary_operation' method in the Calculator service with the message template named 'the request'
    Then the 'result' field in the response object is -5
    And the value '-5' is saved in a key called 'expected'
    And the 'result' field in the response object is the same as the value stored in the key 'expected'
