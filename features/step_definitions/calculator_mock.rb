# frozen_string_literal: true

Then(/^the Calculator Testing Service receives metadata$/) do |table|
  metadata = GrpcApiAssistant::ServiceManager.services.get_service('Calculator').all_metadata
  table.hashes.each do |row|
    key = row[:key]
    expect(metadata[key]).to eq(row[:value])
  end
end

Then 'the Calculator Test Service received a GUID-shaped value in the {string} metadata key' do |key|
  metadata = GrpcApiAssistant::ServiceManager.services.get_service('Calculator').all_metadata
  value = metadata[key]
  expect(value).to match GUID_REGEX
end
