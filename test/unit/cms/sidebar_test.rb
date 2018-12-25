require 'test_helper'

class CMS::SidebarTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @sidebar  = CMS::Sidebar.new(@provider)
  end

  def test_builtins
    page        = FactoryBot.create(:cms_builtin_page, provider: @provider, title: 'a')
    static_page = FactoryBot.create(:cms_builtin_static_page, provider: @provider, title: 'b')

    assert_equal [page, static_page], @sidebar.builtins
    assert @sidebar.builtins.all?{ |x| x.type.present? }
  end

  def test_as_json
    attributes = %i(root sections pages files builtins layouts partials portlets)

    assert_equal @sidebar.as_json.keys, attributes

    CMS::Sidebar.any_instance.stubs(:sections).returns(OpenStruct.new(root: nil))

    assert_equal @sidebar.as_json.keys, attributes
  end
end
