# frozen_string_literal: true

require 'test_helper'

class BackendProviderSyncWorkerTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  def test_provider_sync
    Sidekiq::Testing.inline! do
      Backend::StorageSync.any_instance.expects(:sync_provider)
      BackendProviderSyncWorker.enqueue(@provider.id)
    end
  end
end
