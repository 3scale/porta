# frozen_string_literal: true

require 'test_helper'

class System::DomainInfoTest < ActiveSupport::TestCase
  test '#as_json' do
    domain_info = System::DomainInfo.find('example.com')

    assert_equal({
                   'domain' => 'example.com',
                   'master' => false,
                   'provider' => false,
                   'developer' => false,
                   'apicast' => { 'staging' => false, 'production' => false } },
                 domain_info.as_json)
  end

  test '.find' do
    domain_info = System::DomainInfo.find(master_account.domain)

    assert domain_info.master
    assert domain_info.developer
    refute domain_info.provider
    refute domain_info.apicast_staging
    refute domain_info.apicast_production
  end
end
