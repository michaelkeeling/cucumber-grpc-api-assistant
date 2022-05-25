# Cucumber gRPC API Assistant

A set of Cucumber steps for testing gRPC services.

Features

- Steps for calling gRPC, including using variables
- Steps for dynamically mananaging clients and hand rolled mocks
- Templating system for reusing request templates
- Developer-focused DSL, best suited for technical folks who actually use the APIs under test

## Prerequisites

- Ruby 2.5.7
- Bundler gem

## Installing and Running

```bash
bundle install
rake
```

Running the default Rake task will test and package the gem.

## Usage

Setup

1. Modify your Rakefile to generate the protobuf files. There is an example task in this project's Rakefile.
2. Include the generated ruby protbufs. This can be done by unshifting the path where the generated protobufs landed
   and then including the `*_services_pb` files. Here's an example from the tests for this project, found in
   `features/support/env.rb`

```ruby
$LOAD_PATH.unshift 'generated/proto'
require 'calculator_services_pb'
```

3. Configure clients by adding them to the `GrpcApiAssistant::ClientManager`
4. Configure test doubles by adding them to the ` GrpcApiAssistant::ServerManager` and starting them.
5. Add cleanup code for clients and servers in hooks to avoid leaking data between tests.

### Configure Clients

Within the steps, you can refer to clients for a service by name. The name is just a label you provide so that it's easier
to distinguish between different clients. The simplest way to set this up is by adding a client using a Cucumber hook.
Here's an example:

```ruby
# In features/support.hooks.rb or wherever you store your hooks...
GrpcApiAssistant::ClientManager.clients.add_client(
  'Client Name To Use In Steps',
  '::Service::Package::Name',
  'localhost',
  12345
)
```

The `::Service::Package::Name` is the above example can be looked up in the generated `*_services_pb` file. These
are just the list of module names, excluding the the class `Service`.

So...

```ruby
# in generated/proto/calculator_services_pb.rb
module Calculator
  module Calculator
    class Service
```

Becomes...

```ruby
::Calculator::Calculator
```

### Set a Default Package Prefix for Messages

Within scenarios, you can create messages by providing a name and JSON payload. The JSON will be serialized into the
message type requested (if possible). Messages are defined in the generated `*_pb.rb` files (not `*_services_pb.rb`).
For convenience, you can set a default package prefix as a background step in scenarios to make them a little more
readable.

```gherkin
Given the package prefix is 'ModuleName::'
```

Then when referring to messages, only specify the message name, not the fully qualified class path.

You can look up the package prefix in the generated `*_pb.rb` files. Here's an example.

```ruby
# at the bottom of generated/proto/calculator_pb.rb
module Calculator
  UnaryRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("calculator.UnaryRequest").msgclass
  ...
end
```

The package prefix is `Calculator` while the message name to specify in Gherkin steps is simply `UnaryRequest`. There
are examples of this in `calculator_testing.feature`.

### Templates and Variable Substitutions

You can create request templates and later substitute values in the template based on variables. This is useful for
cleaning up tests to make it more clear what is being checked, but also necessary in cases that involve multiple
operations (e.g. create then update based on an ID provided in the create step). Examples for using templates
are shown in [templates.feature](features/templates.feature)

In addition to declaring your own variables there are a few special values that can be used from templates.

```cucumber
{RANDOM()}
{CURRENT_TIME()}
```

## Test the Gem

The Calculator Service is used to test the Cucumber steps and demonstrate how to implement gRPC test doubles.

## Project Organization

## Todo List

- Clean up the code
  - isolate templating and variable data structures to make extending easier
  - default variables, especially for time, are inconsistent
- Write tests for the secure server examples
- Package and publish the gem

## Contributions

Contributions are welcome. If you are contributing source code, you implicitly acknowledge that the contribution
is your work (in whole or in part) and that you have permission to submit the change under an open source license.
