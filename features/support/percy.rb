require 'percy/capybara'

ENV['PERCY_PARALLEL_TOTAL'] = ENV['PARALLEL_TEST_GROUPS']
ENV['PERCY_PARALLEL_NONCE'] = ENV['BUILD_TAG']


if Percy::Capybara.initialize_build
  # rubocop:disable Style/GlobalVars
  $percy = true
end

at_exit do
  Percy::Capybara.finalize_build
end
