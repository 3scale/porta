# frozen_string_literal: true

require 'test_helper'

class ThreeScale::JobsTest < ActiveSupport::TestCase

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
    serialized = YAML.dump([Account, :new, [{org_name: 'Company'}]])
    assert_equal({klass: "ThreeScale::Jobs::Task", init_args: serialized}, task.serialize)
  end

  def test_task_deserialize
    task = ThreeScale::Jobs::Task.new(Account, :new, org_name: 'Company')
    serialized = YAML.dump([Account, :new, [{org_name: 'Company'}]])
    assert_equal(task, ThreeScale::Jobs::Task.deserialize('klass' => 'ThreeScale::Jobs::Task', 'init_args' => serialized))
  end
end
