Feature: Basic gRPC step functions

  This gem provides a set of basic steps that can be used to drive a gRPC API
  and check the results.

  There are three ways to make a gRPC request.

  1. Call the rpc in a single step.  This is demonstrated in the scenario,
  "Check a whole response object value"
  2. Call the rpc in two steps.  The first step defines the shape of the
  request object, while the second step uses that request object.  This is
  demonstrated in the scenario "Matchers for checking result values".
  3. Call the rpc using a stored template, which holds the request object.
  The stored template can be defined at any point (in the current test
  context) before it is used.  The template is referenced by name when using
  it.  This is demonstrated in the scenario "Call method using a template"

  A variety of step functions allow you to check for errors or values in the
  response. These are demonstrated throughout the scenarios.


  Background:
    Given the package prefix is 'Calculator::'

  Scenario: Matchers for checking result values
    Given an 'UnaryRequest' that looks like the following
      """
      {
        "x": 6,
        "operand": "-"
      }
      """
    And the value -6 is saved in a key called 'saved_value'
    When I call the 'unary_operation' method in the Calculator service
    Then the response object is not an error
    And the 'result' field in the response object has a value
    And the 'some_missing_field' field in the response object does not have a value
    And the 'result' field in the response object is -6
    And the 'result' field in the response object is not 1234
    And the 'result' field in the response object is the same as the value stored in the key 'saved_value'
    And the 'result' field in the response object contains the substring '-'
    And the 'result' field in the response object is less than 0
    And the 'result' field in the response object is greater than -100
    And the 'result' field in the response object has a value in the list [5,-6]

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

  Scenario: Checking error responses
    Given I call the 'binary_operation' method in the Calculator service with a 'BinaryRequest' that looks like
      """
      {
        "x": 2,
        "y": 3,
        "operand": "%"
      }
      """
    Then the response is an error with code 12 and message '12:operand not implemented'
    And the response gives the error code 12

  Scenario: Check a whole response object value, boolean, or empty values
    Given I call the 'binary_operation' method in the Calculator service with a 'BinaryRequest' that looks like
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
    And the 'result' field in the response object is empty
    And the 'boolean_result' field in the response object is false

  Scenario: Check for true values
    Given I call the 'binary_operation' method in the Calculator service with a 'BinaryRequest' that looks like
      """
      {
        "x": 5,
        "y": 5,
        "operand": "=="
      }
      """
    Then the 'boolean_result' field in the response object is true

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
        {
          "x": 1,
          "numeric_result": 1,
          "boolean_result": true
        },
        {
          "x": 2,
          "numeric_result": 2,
          "boolean_result": false
        },
        {
          "x": 3,
          "numeric_result": 3,
          "boolean_result": true
        },
        {
          "x": 4,
          "numeric_result": 4,
          "boolean_result": false
        },
        {
          "x": 5,
          "numeric_result": 5,
          "boolean_result": true
        }
      ]
      """

  Scenario: Simple time comparison checks
    Given I call the 'current_time' method in the Calculator service with an 'Empty' that looks like
      """
      """
    Then the 'ms' field in the response object has a recent millisecond timestamp
    And the 'ms' field in the response object has a timestamp less than 500 milliseconds old
    And the 'ms' field in the response object has a timestamp less than 10 seconds old
    And I wait 2 milliseconds
    And the 'ms' field in the response object has a timestamp at least 1 millisecond old
    And I wait 1000 milliseconds
    And the 'ms' field in the response object has a timestamp at least 1 second old

    Given I call the 'echo_time' method in the Calculator service with a 'TimeRequest' that looks like
      """
      {
        "timestamp": "2023-10-31T01:03:05Z"
      }
      """
    Then the 'timestamp' field in the response object has a timestamp equal to '2023-10-31T01:03:05Z'

    Given I call the 'echo_time' method in the Calculator service with a 'TimeRequest' that looks like
      """
      {

      }
      """
    Then the 'timestamp' field in the response object has a timestamp equal to 'nil'

  Scenario: Checking values using field navigation
    Given an 'MultiUnaryRequest' that looks like the following
      """
      {
        "xs": [
          "1",
          "3",
          "5"
        ],
        "operand": "-"
      }
      """
    When I call the 'multi_unary_operation' method in the Calculator service
    Then the response object is not an error
    And the 'results' field in the response object has 3 values
    And the 'results' field in the response object matches ["-1", "-5", "-3"] as a set
    And the 'results/0' field in the response object is '-1'
    And the 'results/0' field in the response object is not '1000'
    And the 'foo' field in the response object is empty

  Scenario: Matcher for checking a list field does not have a value
    Given an 'MultiUnaryRequest' that looks like the following
      """
      {
        "xs": [],
        "operand": "+"
      }
      """
    When I call the 'multi_unary_operation' method in the Calculator service
    Then the response object is not an error
    And the 'results' field in the response object does not have a value
