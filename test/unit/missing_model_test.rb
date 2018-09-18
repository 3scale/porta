require 'test_helper'

class MissingModelTest < ActiveSupport::TestCase
  test 'find with GlobalId' do
    model = MissingModel.new id: 1
    gid = model.to_global_id
    assert_equal model, GlobalID::Locator.locate(gid)
  end
end
