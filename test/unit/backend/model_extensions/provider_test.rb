# frozen_string_literal: true

require 'test_helper'

class Backend::ModelExtensions::ProviderTest < ActiveSupport::TestCase
  def setup
    @storage = Backend::Storage.instance
    @storage.flushdb
  end

  class ProviderAccountTest < Backend::ModelExtensions::ProviderTest
    def setup
      super
      @subject = FactoryBot.create(:provider_account)
    end

    attr_reader :subject

    test "update backend default_service when set and saved" do
      service = subject.first_service!
      assert_nil subject.default_service_id

      Service.any_instance.expects(:update_backend_service)
      subject.default_service_id = service.id
      subject.save!

      assert_equal service, subject.default_service
    end
  end
end
