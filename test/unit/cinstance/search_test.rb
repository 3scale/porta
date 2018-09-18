require 'test_helper'

class Cinstance::SearchTest < ActiveSupport::TestCase

  def test_by_name
    cinstance = FactoryGirl.create(:cinstance, user_key: 'foobar')

    result = Cinstance.by_name('user_key: foobar')

    assert_equal 1, result.size
    assert_contains result, cinstance

    result = Contract.by_name('user_key: foobar')
    assert_equal 0, result.size
  end

end
