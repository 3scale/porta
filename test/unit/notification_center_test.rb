require 'minitest_helper'
require 'notification_center'

class NotificationCenterTest < MiniTest::Unit::TestCase

  MyClass = Class.new

  def teardown
    NotificationCenter.reset!
  end

  alias setup teardown

  def test_silent_about
    assert_equal Set.new, NotificationCenter.disabled

    NotificationCenter.silent_about(MyClass) do
      assert_equal Set.new([MyClass]), NotificationCenter.disabled
    end

    assert_equal Set.new, NotificationCenter.disabled
  end

  def test_enabled?
    my = MyClass.new
    center = NotificationCenter.new(my)
    assert center.enabled?, 'should be enabled'
    NotificationCenter.disabled = Set.new([MyClass])
    refute center.enabled?, 'should be disabled'
  end

  def test_reset!
    assert_equal Set.new, NotificationCenter.disabled
    NotificationCenter.disabled = Set.new([MyClass])
    assert_equal Set.new([MyClass]), NotificationCenter.disabled

    NotificationCenter.reset!
    assert_equal Set.new, NotificationCenter.disabled
  end
end
