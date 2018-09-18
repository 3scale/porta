require 'test_helper'

class Liquid::Drops::MenuDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @active = {:main_menu => "menu", :submenu => "submenu", :sidebar => "sidebar"}
    @drop = Liquid::Drops::Menu.new(@active)
  end

  test "returns active menu" do
    assert_equal "menu", @drop.active_menu
  end

  test "returns active submenu" do
    assert_equal "submenu", @drop.active_submenu
  end

  test "returns active sidebar" do
    assert_equal "sidebar", @drop.active_sidebar
  end

  test "returns all active menus" do
    assert_equal @active, @drop.active
  end
end
