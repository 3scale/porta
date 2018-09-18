require 'test_helper'

class BackendRandomDataGeneratorWorkerTest < ActiveSupport::TestCase

  def test_generate
    assert_difference BackendRandomDataGeneratorWorker.jobs.method(:size) do
      BackendRandomDataGeneratorWorker.generate({})
    end
  end

  def test_perform
    worker = BackendRandomDataGeneratorWorker.new

    Backend::RandomDataGenerator.expects(:generate).with(foo: 'bar', since: Time.utc(2016, 9, 1))

    worker.perform('foo' => 'bar', 'since' => '2016-09-01 00:00:00 UTC')
  end

end
