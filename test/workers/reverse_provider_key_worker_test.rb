require 'test_helper'

class ReverseProviderKeyWorkerTest < ActiveSupport::TestCase
  def setup
    @worker = ReverseProviderKeyWorker.new
  end

  def test_perform
    provider = FactoryGirl.create(:provider_account)

    app = provider.bought_cinstance
    app.user_key = 'foobar'

    app.save!

    assert_equal 'foobar', provider.provider_key
    assert @worker.perform(provider.id)

    provider.reload

    assert_equal 'raboof', provider.provider_key
  end


  def test_enqueue
    worker = @worker.class
    provider = FactoryGirl.build_stubbed(:simple_provider)
    Sidekiq::Testing.fake! do
      worker.enqueue(provider)

      assert_equal 1, worker.jobs.size

      assert job = worker.jobs.first

      assert_equal [provider.id], job['args']
    end
  end
end
