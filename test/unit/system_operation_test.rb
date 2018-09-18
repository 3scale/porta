require 'test_helper'

class SystemOperationTest < ActiveSupport::TestCase

  def setup
    SystemOperation.delete_all
  end

  def test_for
    assert_equal SystemOperation::DEFAULTS.keys.size, SystemOperation.count

    assert SystemOperation.all.present?
    assert SystemOperation.for('user_signup')
  end
end
