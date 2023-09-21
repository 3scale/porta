# frozen_string_literal: true

require 'test_helper'
require 'kubernetes/tools'

class ToolsTest < ActiveSupport::TestCase

  test 'check if running on kubernetes' do
    Dir.stubs(:exist?).returns(true)
    assert Kubernetes::Tools.running_on_kubernetes?

    Dir.stubs(:exist?).returns(false)
    assert_not Kubernetes::Tools.running_on_kubernetes?

    ENV['KUBERNETES_PORT'] = '1'
    assert Kubernetes::Tools.running_on_kubernetes?
  end

  test 'calculate available_cpus for cgroups v1' do
    File.stubs(:exist?).returns(false)

    # 1024 shares is equivalent to 1 cpu
    File.stubs(:read).returns('2048')
    assert_equal 2, Kubernetes::Tools.available_cpus

    # CPUs number is rounded up
    File.stubs(:read).returns('5000')
    assert_equal 5, Kubernetes::Tools.available_cpus
  end

  test 'calculate available_cpus for cgroups v2' do
    File.stubs(:exist?).returns(true)

    File.stubs(:read).returns('79')
    assert_equal 2, Kubernetes::Tools.available_cpus
  end
end

