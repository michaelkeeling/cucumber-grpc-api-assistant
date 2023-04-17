Then /^the Calculator Testing Service receives metadata$/ do |table|
  metadata = GrpcApiAssistant::ServiceManager.services.get_service("Calculator").get_all_metadata
  table.hashes.each do |row|
    key = row[:key]
    expect(metadata[key]).to eq(row[:value])
  end
end

Then 'the Calculator Test Service received a GUID-shaped value in the {string} metadata key' do |key|
  metadata = GrpcApiAssistant::ServiceManager.services.get_service("Calculator").get_all_metadata
  value = metadata[key]
  expect(value).to match /^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/
end