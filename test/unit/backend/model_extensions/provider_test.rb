require 'test_helper'

class Backend::ModelExtensions::ProviderTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  def setup
    @storage = Backend::Storage.instance
    @storage.flushdb
  end

  context "provider account" do
    subject { FactoryGirl.create :provider_account }

    should "update backend default_service when set and saved" do
      service = subject.first_service!

      assert_nil subject.default_service_id

      subject.default_service_id = service.id

      Service.any_instance.expects(:update_backend_service)
      subject.save!

      assert_equal service, subject.default_service
    end
  end

end
