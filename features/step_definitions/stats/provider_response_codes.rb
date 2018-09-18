When(/^on the response codes chart page$/) do
  visit admin_service_stats_response_codes_path(@provider.first_service!)
end

RESPONSE_CODES = %w[2XX 4XX 5XX].freeze
RESPONSE_CODE_VALUE = 10

Given(/^the provider has response codes stats data$/) do
  storage = Stats::Client.storage
  now = Time.now.utc
  service = @provider.first_service!

  keys = RESPONSE_CODES.flat_map do |code|
    [["stats/{service:#{service.id}}/response_code:#{code}/hour:#{now.at_beginning_of_day.to_s(:compact)}", RESPONSE_CODE_VALUE]]
  end.to_h

  storage.mapped_mset(keys)
end
