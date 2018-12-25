require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class WebHookFailuresTest < ActiveSupport::TestCase

  def setup
    System.redis.flushdb
    @provider = 'provider-id'
    @web_hook_failures = WebHookFailures.new(@provider)
  end

  test '#add adds elements at the end of the list' do
    assert @web_hook_failures.first.nil?

    @web_hook_failures.add({ "id" => "1" })
    @web_hook_failures.add({ "id" => "2" })

    assert_equal("1", @web_hook_failures.first.id)
  end

  test '#all reads all elements in the list' do
    @web_hook_failures.add({ "id" => "1" })
    @web_hook_failures.add({ "id" => "2" })

    web_hook_failures = @web_hook_failures.all
    assert_equal 2, web_hook_failures.size
    assert_equal '1', web_hook_failures.first.id
    assert_equal '2', web_hook_failures.last.id
  end

  test '#delete_all deletes all elements in the list' do
    @web_hook_failures.add({ "id" => "1" })
    @web_hook_failures.add({ "id" => "2" })
    @web_hook_failures.delete_all

    assert @web_hook_failures.empty?
  end

  test '#delete deletes elements with time less than or equal the param passed' do
    @web_hook_failures.add({ "id" => "1", time: Time.parse('2010-01-01') })
    @web_hook_failures.add({ "id" => "2", time: Time.parse('2011-01-01') })
    @web_hook_failures.add({ "id" => "3" , time: Time.parse('2012-01-01 01:02:03')})

    @web_hook_failures.delete_by_time "2011-01-01"

    web_hook_failures = @web_hook_failures.all

    assert_equal 1, web_hook_failures.size
    assert_equal '3', web_hook_failures.first.id
  end

  test '#to_xml expected xml structure' do
    buyer = FactoryBot.build(:buyer_account)
    event = WebHook::Event.new(buyer.provider_account, buyer, :event => 'created')
    xml = event.to_xml

    WebHookFailures.add(@provider, "FakedException", 'uuid', 'url', xml)

    xml = Nokogiri::XML::Document.parse(@web_hook_failures.to_xml)

    assert_xpath xml, "//webhooks-failures/webhooks-failure/id"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/time"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/error", "FakedException"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/event"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/event/action"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/event/type"
    assert_xpath xml, "//webhooks-failures/webhooks-failure/event/object"
  end

  test '#to_xml no double escaping of xml' do
    buyer = FactoryBot.create(:buyer_account)
    event = WebHook::Event.new(buyer.provider_account, buyer, :event => 'updated')
    xml = event.to_xml

    WebHookFailures.add(@provider, "FakedException", 'uuid', 'url', xml)

    xml = @web_hook_failures.to_xml
    refute_match /&gt;/, xml
  end

  test '#delete' do
    @web_hook_failures.expects(:delete_all)
    @web_hook_failures.delete

    @web_hook_failures.expects(:delete_by_time).with('2010-01-01')
    @web_hook_failures.delete('2010-01-01')
  end

  test '-valid_date?' do
    assert WebHookFailures.valid_time?('2010-01-01')
    assert WebHookFailures.valid_time?('2010-01-01 10:10:10')
    refute WebHookFailures.valid_time?('323123122')
  end
end
