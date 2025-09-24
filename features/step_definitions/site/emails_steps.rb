# frozen_string_literal: true

Given "DNS domains {are} readonly" do |readonly|
  Rails.application.config.three_scale.expects(:readonly_custom_domains_settings).returns(readonly)
end

# Then they should see the following custom support emails:
#   | Bananas | help@bananas.org    |
#   | Oranges | support@oranges.com |
Then "they should see the following custom support emails:" do |table|
  table.rows_hash.each do |key, value|
    assert_equal value, find_field(key).value
  end
end

Then "they should see no custom support emails" do
  assert_empty find_all('#custom-support-emails input')
end
