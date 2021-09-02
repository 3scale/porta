require 'test_helper'


class ProxyRuleTest < ActiveSupport::TestCase
  test 'patterns' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)

    assert_valid proxy_rule

    %w(
      /
      /test/
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
    ).each do |pattern|
      proxy_rule.pattern = pattern
      assert_valid proxy_rule, "#{pattern} should be valid"
    end

    [' http://www.url.com/something.asmx', 'http://www.url.com/something.asmx HTTP/1.1', '', 'foo', '/foo?{a}=bar', '/micro$oft', '/$$'].each do |pattern|
      proxy_rule.pattern = pattern

      refute_valid proxy_rule, "#{pattern} should be invalid"
      assert proxy_rule.errors[:pattern], pattern.presence
    end
  end

  test 'duplicated vars' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)
    proxy_rule.pattern = "/foo/{bar}/baz/{bar}/quux"
    refute_valid proxy_rule
    assert proxy_rule.errors[:pattern].presence
  end

  test 'duplicated params with var and var' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)
    proxy_rule.pattern = "/foo/bar/baz?a={foo}&a={bar}"
    refute_valid proxy_rule
    assert proxy_rule.errors[:pattern].presence
  end

  test 'duplicated params with var and fixed' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)
    proxy_rule.pattern = "/foo/bar/baz?a=foo&a={bar}"
    refute_valid proxy_rule
    assert proxy_rule.errors[:pattern].presence
  end

  test 'duplicated params with fixed and fixed' do
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule)
    proxy_rule.pattern = "/foo/bar/baz?a=foo&a={bar}"
    refute_valid proxy_rule
    assert proxy_rule.errors[:pattern].presence
  end

  test 'params in path' do
    proxy_rule = ProxyRule.new(:pattern => "/foo/{word}/{item}.json")
    assert_equal 'word' ,  proxy_rule.parameters.first
    assert_equal 'item' ,  proxy_rule.parameters.last
  end

  test 'params in the querystring' do
    proxy_rule = ProxyRule.new(:pattern => "/foo/word/{item}.json?action={action}")
    assert_equal ['action', '{action}'] , proxy_rule.querystring_parameters.first
  end

  test 'params in the querystring without {brackets} are not unordered' do
    proxy_rule = ProxyRule.new(:pattern => "/foo/word/{item}.json?foo=bar&action={action}")
    assert_equal 'bar', proxy_rule.querystring_parameters["foo"]
    assert_equal '{action}' , proxy_rule.querystring_parameters["action"]
    assert_equal 2 , proxy_rule.querystring_parameters.size
  end

  test 'pattern ending with ? works' do
    proxy_rule = ProxyRule.new(:pattern => "/foo/word/{item}.json?")
    assert_equal Hash.new , proxy_rule.querystring_parameters
  end

  # Regression test for https://github.com/3scale/system/issues/5898
  test 'pattern with more than 1 = per & should not raise error' do
    proxy_rule = ProxyRule.new(:pattern => "?foo=bar=lol")
    assert_equal({"foo" => "bar=lol"}, proxy_rule.querystring_parameters)
  end

  test 'when pattern is nil, path_pattern and query_pattern return empty values instead of raising errors' do
    proxy_rule = ProxyRule.new
    assert_equal '', proxy_rule.path_pattern
    assert_nil proxy_rule.query_pattern
  end

  test 'redirect_url' do
    # should accept a nil value
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, redirect_url: nil)
    assert_valid proxy_rule

    # should validate that is an URL
    proxy_rule = FactoryBot.build_stubbed(:proxy_rule, redirect_url: 'foo')
    refute_valid proxy_rule

    # should accept an url with http
    proxy_rule.redirect_url = 'http://example.com/foo/bar?foo=bar&bar=foo'
    assert_valid proxy_rule

    # should accept an url with http
    proxy_rule.redirect_url = 'https://example.com/foo/bar?foo=bar&bar=foo'
    assert_valid proxy_rule

    # should do not accept url without protocol
    proxy_rule.redirect_url = '//example.com/foo/bar?foo=bar&bar=foo'
    refute_valid proxy_rule

    # should do not accept other protocols
    proxy_rule.redirect_url = 'ftp//example.com/foo/bar?foo=bar&bar=foo'
    refute_valid proxy_rule

    # should not accept string of more than 10000 characters
    proxy_rule.redirect_url = "https://example.com/#{'1' * 9981}"
    refute_valid proxy_rule
  end

  test 'save' do
    proxy_rule = FactoryBot.build(:proxy_rule, redirect_url: nil)
    # should accept string up to 10000 characters
    assert FactoryBot.create(:proxy_rule, redirect_url: "https://example.com/#{'1' * 9980}")
  end

  test 'fill owner' do
    provider = FactoryBot.create(:simple_provider)

    proxy = FactoryBot.create(:service, account: provider).proxy
    proxy_proxy_rule = FactoryBot.build(:proxy_rule, proxy: proxy, metric: FactoryBot.create(:metric))
    refute proxy_proxy_rule.owner
    assert proxy_proxy_rule.valid?
    assert_equal proxy, proxy_proxy_rule.owner

    backend_api = FactoryBot.create(:backend_api, name: 'API', system_name: 'api', account: provider)
    backend_proxy_rule = FactoryBot.build(:proxy_rule, proxy: nil, owner: backend_api, metric: FactoryBot.create(:metric))
    assert_equal backend_api, backend_proxy_rule.owner
    assert backend_proxy_rule.valid?
  end

  class PositionUpdateOnConcurrentDeletion < ActiveSupport::TestCase
    disable_transactional_fixtures!

    setup do
      @provider = FactoryBot.create(:simple_provider)
    end

    attr_reader :provider

    test 'position is not updated when account has been deleted' do
      proxy = FactoryBot.create(:service, account: provider).proxy
      proxy_rule = FactoryBot.create(:proxy_rule, proxy: proxy)

      provider.delete

      proxy_rule.expects(:decrement_positions_on_lower_items).never
      proxy_rule.reload.destroy
    end

    test 'position is not updated when owner proxy has been deleted' do
      proxy = FactoryBot.create(:service, account: provider).proxy
      proxy_rule = FactoryBot.create(:proxy_rule, proxy: proxy)

      proxy.delete

      proxy_rule.expects(:decrement_positions_on_lower_items).never
      proxy_rule.reload.destroy
    end

    test 'position is not updated when owner backend has been deleted' do
      backend_api = FactoryBot.create(:backend_api, account: provider)
      proxy_rule = FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil)

      backend_api.mark_as_deleted

      proxy_rule.expects(:decrement_positions_on_lower_items).never
      proxy_rule.reload.destroy
    end
  end

  module ProxyConfigAffectingChangesTest
    class ProxyOwned < ActiveSupport::TestCase
      disable_transactional_fixtures!

      setup do
        @proxy = FactoryBot.create(:simple_proxy)
      end

      attr_reader :proxy

      include ProxyConfigAffectingChangesTest

      def create_proxy_rule
        FactoryBot.create(:proxy_rule, proxy: proxy)
      end
    end

    class BackendApiOwned < ActiveSupport::TestCase
      disable_transactional_fixtures!

      setup do
        service = FactoryBot.create(:simple_service)
        @backend_api = FactoryBot.create(:backend_api, account: service.account)
        FactoryBot.create(:backend_api_config, backend_api: backend_api, service: service)
      end

      attr_reader :backend_api

      include ProxyConfigAffectingChangesTest

      def create_proxy_rule
        FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil)
      end
    end

    def test_tracks_changes_on_create
      with_proxy_config_affecting_changes_tracker do |tracker|
        proxy_rule = create_proxy_rule
        assert tracker.tracking?(ProxyConfigAffectingChanges::TrackedObject.new(proxy_rule))
      end
    end

    def tracks_changes_on_update
      proxy_rule = create_proxy_rule
      tracked_object = ProxyConfigAffectingChanges::TrackedObject.new(proxy_rule)

      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        proxy_rule.update(pattern: '/new-pattern')
        assert tracker.tracking?(tracked_object)
      end
    end

    def tracks_changes_on_destroy
      proxy_rule = create_proxy_rule
      tracked_object = ProxyConfigAffectingChanges::TrackedObject.new(proxy_rule)

      with_proxy_config_affecting_changes_tracker do |tracker|
        refute tracker.tracking?(tracked_object)
        proxy_rule.destroy
        assert tracker.tracking?(tracked_object)
      end
    end
  end
end
