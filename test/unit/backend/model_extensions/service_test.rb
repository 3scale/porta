require 'test_helper'

class Backend::ModelExtensions::ServiceTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  test 'stores backend service data when service is saved' do
    service = FactoryBot.build(:service,
      account: FactoryBot.create(:provider_account), referrer_filters_required: true)

    ThreeScale::Core::Service.expects(:save!).with do |params|
      params[:id] == service.backend_id &&
        params[:referrer_filters_required] == true
    end

    service.save!
  end

  test 'deletes backend service data when service is destroyed' do
    service = FactoryBot.create(:service, metrics: [])

    service.stubs(:alert_limits).returns([100, 200])
    backend_id = service.backend_id
    ThreeScale::Core::Service.expects(:delete_by_id!).with(backend_id)
    ThreeScale::Core::AlertLimit.expects(:delete).with(backend_id, 100).once
    ThreeScale::Core::AlertLimit.expects(:delete).with(backend_id, 200).once

    service.destroy
  end

  test 'updates notification settings to backend' do
    service = FactoryBot.create(:simple_service)

    service.expects(:update_notification_settings)

    service.notification_settings = { buyer_web: [50] }
    service.save
  end
end
