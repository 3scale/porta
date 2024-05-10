require 'test_helper'

class OracleHacksTest < ActiveSupport::TestCase
  test "using #with_lock block" do
    object = FactoryBot.create(:audit)
    assert( object.with_lock { :ok } )
  end
end
