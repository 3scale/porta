# frozen_string_literal: true

require 'test_helper'

class ThreeScale::JobsTest < ActiveSupport::TestCase

  include ActiveJob::TestHelper

  def test_task_run
    task = ThreeScale::Jobs::Task.new(String, :new, 'hello world')
    task.run
  end

  def test_rake_task_run
    ::Rake.application = ::Rake::Application.new
    rake = Rake::Task.define_task 'foo'
    rake.expects(:invoke)
    rake.expects(:reenable)
    task = ThreeScale::Jobs::RakeTask.new('foo')
    task.run
  end

  def test_rake_task_serialize
    task = ThreeScale::Jobs::RakeTask.new('foo')
    assert_equal({klass: "ThreeScale::Jobs::RakeTask", init_args: ["foo"]}, task.serialize)
  end

  def test_task_serialize
    task = ThreeScale::Jobs::Task.new(Account, :new, org_name: 'Company')
    serialized = YAML.dump([Account, :new, {org_name: 'Company'}])
    assert_equal({klass: "ThreeScale::Jobs::Task", init_args: serialized}, task.serialize)
  end

  def test_task_deserialize
    task = ThreeScale::Jobs::Task.new(Account, :new, org_name: 'Company')
    serialized = YAML.dump([Account, :new, [{org_name: 'Company'}]])
    assert_equal(task, ThreeScale::Jobs::Task.deserialize(klass: 'ThreeScale::Jobs::Task', init_args: serialized))
  end

  def test_backward_compatibility_deserialize
    serialized = "DestroyAllDeletedObjectsWorker.perform_later(Service.to_s)"
    task = ThreeScale::Jobs::StringEvaluator.new(serialized)
    assert_equal(task, ThreeScale::Jobs::Task.deserialize(serialized))
    assert_enqueued_with job: DestroyAllDeletedObjectsWorker, args: ['Service'] do
      task.run
    end
  end

  def test_backward_compatibility_rake_deserialize
    serialized = {'rake' => 'sphinx:enqueue'}
    task = ThreeScale::Jobs::RakeTask.new('sphinx:enqueue')
    assert_equal(task, ThreeScale::Jobs::Task.deserialize(serialized))
  end

  include ThreeScale::Jobs

  ALL = MONTH + DAILY + BILLING + HOUR

  ALL.each do |job|
    define_method("test_#{job.name}") do
      FactoryBot.create(:provider_account)
      job.run
    end
  end
end
