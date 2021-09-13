Then /^the Calculator Testing Service receives metadata$/ do |table|
  metadata = GrpcApiAssistant::ServiceManager.services.get_service("Calculator").get_all_metadata
  table.hashes.each do |row|
    key = row[:key]
    expect(metadata[key]).to eq(row[:value])
  end
end
