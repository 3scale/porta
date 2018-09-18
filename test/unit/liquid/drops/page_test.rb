require 'test_helper'

class Liquid::Drops::PageTest < ActiveSupport::TestCase
  test 'returns system_name' do
    drop =  Liquid::Drops::Page.new(mock('page', :system_name => 'my system name'))
    assert_equal 'my system name', drop.system_name
  end
end
