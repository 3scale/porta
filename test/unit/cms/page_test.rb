require 'test_helper'

class PageTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'set default mime type on initialize' do
    page = CMS::Page.new
    assert_equal CMS::Page::DEFAULT_CONTENT_TYPE, page.content_type
  end

  test 'default content type should be text/html' do
    assert_equal('text/html', CMS::Page::DEFAULT_CONTENT_TYPE)
  end

  test 'path should be normalized' do
    @page = FactoryBot.build(:cms_page, :provider => @provider, :path => " do whatever  / you want ")
    assert @page.invalid?
    assert_equal "do-whatever/you-want", @page.path
    assert @page.errors[:path].include? "needs to start with a slash ( / )"
  end

  test 'page is renderable without layout' do
    @page = FactoryBot.build(:cms_page, :provider => @provider)
    assert_nil @page.layout
  end

  test 'page can have a layout' do
    @page = FactoryBot.build(:cms_page, :layout => FactoryBot.create(:cms_layout), :provider => @provider)
    assert_not_nil @page.layout
  end

  test "page is hidden if published is nil" do
    @page = FactoryBot.build(:cms_page, :draft => 'foo', :published => nil, :provider => @provider)
    assert @page.hidden?
  end

  test "page is visible if it is published" do
    @page = FactoryBot.build(:cms_page, :draft => 'foo', :published => 'foo', :provider => @provider)
    assert @page.visible?
  end

  test 'searchable true for simple templates' do
    page = FactoryBot.create(:cms_page, :draft => 'something to publish')
    page.publish!
    assert page.searchable?
  end

  test 'searchable true for simple blank content type' do
    page = FactoryBot.create(:cms_page, :draft => 'something to publish', :content_type => "")
    page.publish!
    assert page.searchable?
  end

  test 'searchable true for nil content type' do
    page = FactoryBot.create(:cms_page, :draft => 'something to publish', :content_type => nil)
    page.publish!
    assert page.searchable?
  end

  test 'searchable true when there are only includes' do
    source = "hello, {% include 'f' %} kitty"
    page = FactoryBot.create(:cms_page, :draft => source)
    page.publish!
    assert page.searchable?
  end

  test 'not searchable when there is liquid and it is enabled' do
    source = "hello, {% include 'f' %} {% if user_name == 'bob' %} {{ user_name }} {% else %} lalalal {% endif %}"
    page = FactoryBot.create(:cms_page, :draft => source, :liquid_enabled => true)
    page.publish!
    assert !page.searchable?
  end

  test 'searchable when there is liquid but liquid is disabled' do
    source = "hello, {% include 'f' %} {% if user_name == 'bob' %} {{ user_name }} {% else %} lalalal {% endif %}"
    page = FactoryBot.create(:cms_page, :draft => source, :liquid_enabled => false)
    page.publish!
    assert page.searchable?
  end

  test 'not searchable when not html' do
    page = FactoryBot.create(:cms_page, :published => 'simple page', :content_type => 'text/whatever')
    assert ! page.searchable?
  end

  test "tags N+1 queries for tags" do
    page = FactoryBot.create(:cms_page)
    page.expects(:tag_list).never
    page.as_json
  end

  test "as_json returns tag_list when requested" do
    page = FactoryBot.create(:cms_page)
    page.expects(:tag_list).returns([]).once
    page.as_json(include: [:tag_list])
  end

  test 'generates a system_name with proper format from title when creating' do
    page = CMS::Page.new.tap do |p|
      p.title = 'New Page'
      p.provider = @provider
      p.section = @provider.sections.root
      p.path = '/new-page'
    end

    page.save!

    assert_equal 'new-page', page.reload.system_name
  end

  test 'generates a system_name with proper format from title when updating' do
    page = CMS::Page.new.tap do |p|
      p.title = 'New Page'
      p.system_name = 'sysname-1'
      p.provider = @provider
      p.section = @provider.sections.root
      p.path = '/new-page'
    end
    page.save!

    page.system_name = ''
    page.save!

    assert_equal 'new-page', page.reload.system_name
  end

  test "doesn't generate a system_name when one is given" do
    sysname = 'sysname-1'
    page = CMS::Page.new.tap do |p|
      p.title = 'New Page'
      p.system_name = sysname
      p.provider = @provider
      p.section = @provider.sections.root
      p.path = '/new-page'
    end

    page.save!

    assert_equal sysname, page.reload.system_name
  end

  test "raises an error when an invalid system_name is given" do
    page = CMS::Page.new.tap do |p|
      p.title = 'New Page'
      p.system_name = 'sysname 1'
      p.provider = @provider
      p.section = @provider.sections.root
      p.path = '/new-page'
    end

    assert_raise(ActiveRecord::RecordInvalid) { page.save! }
  end
end
