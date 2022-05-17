ParameterType(
  name:        'boolean',
  regexp:      /true|false/,
  transformer: ->(s) { s == 'true' }
)
