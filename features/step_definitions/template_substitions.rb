require 'time'

Then 'the value stored in the key {string} is {string}' do |key_name, expected_value|
  expect(@stored_known_values[key_name]).to eq expected_value
end

Then 'the value stored in the key {string} is a GUID-shaped value' do |key_name|
  expect(@stored_known_values[key_name]).to match GUID_REGEX
end

Then 'the value stored in the key {string} is close to the current time' do |key_name|
  value = @stored_known_values[key_name]
  
  time_value = if value.to_i.to_s == value # we're dealing with ms
    Time.at(value.to_i)
  else # it's a timestamp string
    Time.parse(value)
  end

  expect(time_value).to be_within(1).of(Time.now)
end
