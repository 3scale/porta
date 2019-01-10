require 'test_helper'

class SignupWorkerTest < ActiveSupport::TestCase

  def test_enqueue
    assert SignupWorker.enqueue(stub('provider', id: 42))

    assert_equal 1, SignupWorker.jobs.size
  end

  def test_perform
    SignupWorker.new.perform(42)

    assert_equal 0, SignupWorker.jobs.size
    assert_equal 1, SignupWorker::SampleDataWorker.jobs.size
    assert_equal 1, SignupWorker::ImportSimpleLayoutWorker.jobs.size
  end


  def test_sample_data_worker
    provider = FactoryBot.create(:simple_provider)

    Sidekiq::Testing.inline! do
      SignupWorker::SampleDataWorker.perform_async(provider.id)
    end

    provider.reload

    refute provider.sample_data
  end

  def test_import_simple_layout_worker
    provider = FactoryBot.create(:provider_account)

    assert_equal 0, provider.pages.count

    Sidekiq::Testing.inline! do
      SignupWorker::ImportSimpleLayoutWorker.perform_async(provider.id)
    end

    assert_operator provider.pages.count, :>, 1
  end
end
