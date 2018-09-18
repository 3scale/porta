require 'test_helper'

class Events::ApplicationEnabledChangedTest < ActiveSupport::TestCase
  test '.valid?' do
    assert Applications::ApplicationEnabledChangedEvent.valid? Cinstance.new
    refute Applications::ApplicationEnabledChangedEvent.valid? AccountContract.new
  end
end
