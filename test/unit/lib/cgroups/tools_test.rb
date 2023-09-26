# frozen_string_literal: true

require 'test_helper'
require 'cgroups/tools'

class ToolsTest < ActiveSupport::TestCase

  test 'calculate available_cpus for cgroups v1' do
    File.stubs(:exist?).returns(false)

    # 1024 shares is equivalent to 1 cpu
    File.stubs(:read).returns('4096')
    assert_equal 4, Cgroups::Tools.available_cpus

    # CPUs number is rounded up
    File.stubs(:read).returns('5000')
    assert_equal 5, Cgroups::Tools.available_cpus
  end

  test 'calculate available_cpus for cgroups v2' do
    File.stubs(:exist?).returns(true)

    File.stubs(:read).returns('79')
    assert_equal 2, Cgroups::Tools.available_cpus
  end
end

