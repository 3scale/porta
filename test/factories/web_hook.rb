FactoryBot.define do
 factory(:web_hook) do
  account_id { 0 }
  url { 'http://example.net' }
  active { true }
 end
end
