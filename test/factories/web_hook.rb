Factory.define(:web_hook) do |factory|
  factory.account_id 0
  factory.url 'http://example.net'
  factory.active true
end
