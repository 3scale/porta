require 'test_helper'

class HerokuWorkerTest < ActiveSupport::TestCase
  def test_perform
    provider = FactoryGirl.create(:simple_provider)

    Heroku.expects(:sync).with(provider)

    HerokuWorker.new.perform(provider.id)
  end

  def test_sync
    HerokuWorker.sync(42)

    assert_equal 1, HerokuWorker.jobs.size
  end
end
