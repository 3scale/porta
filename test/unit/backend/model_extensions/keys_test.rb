require 'test_helper'

class KeyTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  test 'destroy a buyer account should destroy the application keys in backend' do
    ak = application_key
    cinstance = ak.application
    buyer = cinstance.buyer
    ApplicationKey.any_instance.expects(:destroy_backend_value)

    ThreeScale::Core::Application.expects(:delete).with(cinstance.service.backend_id, cinstance.application_id)
    # Cinstance.any_instance.expects(:delete_backend_application)
    buyer.destroy
    assert_raise(ActiveRecord::RecordNotFound){ ak.reload }
  end

  test 'destroy a buyer account with custom application should destroy the application keys in backend' do
    ak = application_key
    cinstance = ak.application
    cinstance.customize_plan!
    buyer = cinstance.buyer

    expect_backend_delete_key(cinstance, ak.value)
    ThreeScale::Core::Application.expects(:delete).with(cinstance.service.backend_id, cinstance.application_id)
    buyer.destroy
    assert_raise(ActiveRecord::RecordNotFound){ ak.reload }
  end

  test 'destroy_backend_value should be called before delete_backend_application and destroy a cinstance' do
    ak = application_key
    cinstance = ak.application

    cinstance.reload
    seq = sequence('destroy sequence')
    ApplicationKey.any_instance.expects(:destroy_backend_value).in_sequence(seq)
    cinstance.expects(:delete_backend_application).in_sequence(seq)
    cinstance.destroy
  end

  def application_key
    BackendClient::ToggleBackend.without_backend { FactoryBot.create(:application_key) }
  ensure
    ApplicationKey.stubs(:backend_enabled?).returns(true)
  end
end
