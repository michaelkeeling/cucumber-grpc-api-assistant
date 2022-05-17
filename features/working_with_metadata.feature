Feature: Working with Metadata

  In gRPC, metadata in the form of key-value pairs can be sent with a request
  object, very similar to HTTP headers.  To define metadata using Gherkin steps,
  declare the keys and values in a table.

  This scenario uses a mock service to confirm that the metadata was
  received.  The final check is a custom step not included in the gem.
  In practice, you might need to use logs or other discernable output
  from the request to confirm metadata is correctly processed.

  Like message templates, it's possible to substitute a particular metadata
  value at runtime from a stored variable.



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
    And the value 'ANY_DATA' is saved in a key called 'anything'
    And the grpc metadata keys and values are set as
      | key               | value        |
      | some_key          | key_number_1 |
      | another_key       | key_number_2 |
      | substituted_value | {anything}   |
    When I call the 'unary_operation' method in the Calculator service
    Then the response object is not an error
    And the Calculator Testing Service receives metadata
      | key               | value        |
      | some_key          | key_number_1 |
      | another_key       | key_number_2 |
      | substituted_value | ANY_DATA     |
