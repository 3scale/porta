require 'test_helper'

class CMS::SectionTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:provider_account)
    @buyer = Factory(:buyer_account)
    @root = @provider.sections.first
  end

  test 'should not crash if required parameters are not present' do
    section= CMS::Section.new

    refute section.valid?
  end

  test 'partial_path should be normalized' do
    @section = Factory.build(:cms_section, :parent => @root, :partial_path => " do whatever / you want ")
    assert @section.invalid?, "section should be valid"
    assert_equal "do-whatever/you-want", @section.partial_path
    assert_valid @section
  end

  test "root section assigned to provider" do
    assert_equal 1, @provider.sections.size
  end

  # regression for https://3scale.airbrake.io/groups/56435125
  test "root section can't be deleted" do
    assert !@root.respond_to?(:destroy), 'root must not respond to destroy'
  end

  test "behave ok when current_user = nil" do
    assert @root.accessible_by?(nil)
    @root.public = false
    assert !@root.accessible_by?(nil)
  end

  test "be destroyed cleanly" do
    child = @root.children.create!(:title => 'child', :provider => @provider)
    child.destroy
    assert @root.reload.children.empty?
  end

  # Check for overlapping with add_remove_by_ids
  test "destroy moves children up" do
    child = @root.children.create!(:title => 'child', :provider => @provider)
    gchild = child.children.create!(:title => 'gchild', :provider => @provider)
    page = Factory(:cms_page, :section => child, :provider => @provider)
    bpage = Factory(:cms_builtin_page, :section => child, :provider => @provider)
    child.destroy

    assert_contains @root.pages,  page
    assert_contains @root.builtins,  bpage
  end

  test "adding incorrect type" do
    child = @root.children.create!(:title => 'child', :system_name => 'child', :provider => @provider)
    sec2 = @root.children.create!(:title => 'sec2', :system_name => 'sec2', :provider => @provider)
    sec3 = @root.children.create!(:title => 'sec3', :system_name => 'sec3', :provider => @provider)

    sec2.add_remove_by_ids(:section, [sec3.id])
    assert_contains sec2.children(true), sec3
  end

  test "adding child sections" do
    child = @root.children.create!(:title => 'child', :system_name => 'child', :provider => @provider)
    sec2 = @root.children.create!(:title => 'sec2', :system_name => 'sec2', :provider => @provider)
    sec3 = @root.children.create!(:title => 'sec3', :system_name => 'sec3', :provider => @provider)

    sec2.add_remove_by_ids(:section, [sec3.id])
    assert_contains sec2.children(true), sec3
  end

  test "cannot include itself as a child" do
    child = @root.children.create!(:title => 'child', :system_name => 'child', :provider => @provider)
    sec2 = @root.children.create!(:title => 'sec2', :system_name => 'sec2', :provider => @provider)
    sec3 = @root.children.create!(:title => 'sec3', :system_name => 'sec3', :provider => @provider)

    sec2.add_remove_by_ids(:section, [sec2.id])
    assert !(sec2.children(true).member? sec2)
  end

  test "cannot include itself as a child of a child" do
    child = @root.children.create!(:title => 'child', :system_name => 'child', :provider => @provider)
    sec2 = @root.children.create!(:title => 'sec2', :system_name => 'sec2', :provider => @provider)
    sec3 = @root.children.create!(:title => 'sec3', :system_name => 'sec3', :provider => @provider)

    sec3.add_remove_by_ids(:section, [sec2.id])
    assert !(sec2.children(true).member? sec2)
  end

  test "removes subsections" do
    child = @root.children.create!(:title => 'child', :system_name => 'child', :provider => @provider)
    sec2 = child.children.create!(:title => 'sec2', :system_name => 'sec2', :provider => @provider)
    sec3 = sec2.children.create!(:title => 'sec3', :system_name => 'sec3', :provider => @provider)

    sec2.add_remove_by_ids(:section, [sec3.id])

    assert !(sec2.children(true).member? sec3)
    assert_contains @root.children, sec3
  end

  test 'provider deletion cascades to sections' do
    @provider2 = Factory(:provider_account)
    @provider.destroy
    assert_nil CMS::Section.find_by_provider_id(@provider.id)
    assert_not_nil CMS::Section.find_by_provider_id(@provider2.id)
  end
end
