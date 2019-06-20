require 'test_helper'

class Tasks::ZyncTest < ActiveSupport::TestCase
  setup do
    FactoryBot.create(:provider_account)
  end

  test 'resync provider domains' do
    Account.providers_with_master.each { |account| Domains::ProviderDomainsChangedEvent.expects(:create_and_publish!).with(account) }
    execute_rake_task 'zync.rake', 'zync:resync:provider_domains'
  end

  test 'resync proxy domains' do
    Service.all.each { |service| Domains::ProxyDomainsChangedEvent.expects(:create_and_publish!).with(service.proxy) }
    execute_rake_task 'zync.rake', 'zync:resync:proxy_domains'
  end
end
