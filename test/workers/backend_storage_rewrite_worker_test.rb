# frozen_string_literal: true

require 'test_helper'

class BackendStorageRewriteWorkerTest < ActiveSupport::TestCase
  attr_accessor :provider

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  test '#enqueue' do
    BackendStorageRewriteWorker.enqueue(provider.id)

    assert_equal 1, BackendStorageRewriteWorker.jobs.size
  end

  test '#perform enqueued' do
    Sidekiq::Testing.inline! do
      Backend::StorageRewrite.expects(:rewrite_provider).with(provider.id)
      BackendStorageRewriteWorker.enqueue(provider.id)
    end
  end
end
