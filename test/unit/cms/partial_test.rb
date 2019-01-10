require 'test_helper'

class PartialTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  test 'should not use builtin partials system_names' do
    partial = @provider.partials.create(system_name: 'applications/form')
    assert_not_empty partial.errors[:system_name]
  end

  test 'should not use legal terms system_names' do
    partial = @provider.partials.create(system_name: 'signup_licence')
    assert_not_empty partial.errors[:system_name]
  end

end
