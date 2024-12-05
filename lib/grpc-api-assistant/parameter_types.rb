# frozen_string_literal: true

ParameterType(
  name: 'boolean',
  regexp: /true|false/,
  transformer: ->(s) { s == 'true' }
)

ParameterType(
  name: 'StringList',
  regexp: /\[.+\]/,
  transformer: ->(s) { s.gsub(/\[|\]/, '').split(',') }
)

# Since this regex is the same as other lists, we are relying on the name of the
# step to differentiate the type.
ParameterType(
  name: 'Set',
  regexp: /\[.+\]/,
  transformer: ->(s) { JSON.parse(s).to_set }
)
