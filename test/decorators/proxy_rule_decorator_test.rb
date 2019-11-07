# frozen_string_literal: true

require 'test_helper'

class ProxyRuleDecoratorTest < Draper::TestCase
  setup do
    @backend_api = FactoryBot.create(:backend_api)
  end

  attr_reader :backend_api, :service

  test '#pattern' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello')
    decorator = proxy_rule.decorate
    assert_equal '/hello', decorator.pattern
  end

  test 'catch-all pattern' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/')
    decorator = proxy_rule.decorate
    assert_equal '/', decorator.pattern
  end

  test '#pattern for backend with simple path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello')
    decorator = proxy_rule.decorate(context: { backend_api_path: 'mybackend' })
    assert_equal '/mybackend/hello', decorator.pattern
  end

  test '#pattern for backend with complex path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello')
    decorator = proxy_rule.decorate(context: { backend_api_path: '/mybackend/v2' })
    assert_equal '/mybackend/v2/hello', decorator.pattern
  end

  test '#pattern with trailing slash' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/hello/')
    decorator = proxy_rule.decorate(context: { backend_api_path: 'mybackend' })
    assert_equal '/mybackend/hello', decorator.pattern
  end

  test 'catch-all pattern for backend with simple path' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: '/')
    decorator = proxy_rule.decorate(context: { backend_api_path: 'mybackend' })
    assert_equal '/mybackend', decorator.pattern
  end

  test 'complex patterns' do
    patterns = %w(
      /foo/{bar}/baz/{foo}/quux
      /foo/{whatever}.json
      /foo/bar.json
      /foo.ext1/bar.ext2
      /v1/word/{word}.json?app_id={app_id}&app_key={app_key}
      /foo$
      /foo$?bar=baz
      /$
      /TWAPData;{StartDateTime};{EndDateTime};{CurrencyPair},{ResponseType},{UserName},{Password}
      /service1.svc/securejson/getdata/Tick;16122016100000;16122016100001;GBPJPY;,JSON,Username,Password
      /business-central/rest/runtime/com.redhat.demos:BuildEntAppIn60Min:3.0/withvars/process/project1.SummitDemo/start
      /TWAPDATA;{startDateTime};{endDateTime};{currencyPair},{responseType}
      /optaplanner-webexamples-6.5.0.Final-redhat-2/rest/vehiclerouting/solution/solve
      /optaplanner-webexamples-6.5.0.final-redhat-2/rest/vehiclerouting/solution/solve
      /foo{lal}/
      /foo/{bar}k/baz/{p}/quux
      /http://www.url.com/something.asmx/
    )
    patterns.each do |pattern|
      proxy_rule = FactoryBot.build_stubbed(:proxy_rule, owner: backend_api, pattern: pattern)
      decorator = proxy_rule.decorate
      assert_equal (pattern.ends_with?('/') ? pattern[0...-1] : pattern), decorator.pattern
    end
  end
end
