Feature: Basic gRPC step functions

  This feature will be used to provide generic service testing
  for the grpc-api-assistant gem.

  Background:
    Given the package prefix is 'Calculator::'

  Scenario: Call method with metadata and confirm metadata has been received
    Given an 'UnaryRequest' that looks like the following
      """
      {
        "x": 1,
        "operand": "-"
      }
      """
    And the grpc metadata keys and values are set as
      | key         | value        |
      | some_key    | key_number_1 |
      | another_key | key_number_2 |
    When I call the 'unary_operation' method in the Calculator service
    Then the response object is not an error
    And the Calculator Testing Service receives metadata
      | key         | value        |
      | some_key    | key_number_1 |
      | another_key | key_number_2 |
