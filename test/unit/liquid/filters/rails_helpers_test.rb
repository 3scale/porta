require 'test_helper'

class Liquid::Filters::RailsHelpersTest < ActiveSupport::TestCase
  include Liquid
  include Liquid::Filters::RailsHelpers

  def setup
    @context = Context.new
  end

  test 'javascript_include_tag' do
    @context.registers[:controller] = ApplicationController.new
    Webpacker.manifest.stubs(:lookup).with('stats.js').returns('/packs/stats.js')
    assert_equal "<script src=\"/packs/stats.js\"></script>", javascript_include_tag('stats.js')
  end

  test 'mail_to' do
    assert_equal '<a href="mailto:some@address.com">some@address.com</a>', mail_to('some@address.com')
  end

  test 'pluralize' do
    assert_equal 'plumbers', pluralize('plumber')
  end

  test 'html_safe' do
    assert html_safe('unsafe').html_safe?
  end

  test 'stylesheet_link_tag' do
    assert_equal '<link rel="stylesheet" type="text/css" media="screen" href="/test.css" />', stylesheet_link_tag('/test.css')
  end

  # regression test for https://github.com/3scale/system/issues/2548
  test '#group_by and collection: nil' do
    class Dummy
      include Liquid::Filters::RailsHelpers
    end
    dummy = Dummy.new
    assert_nil dummy.group_by(nil, 'foo')
  end

  # regression test for https://github.com/3scale/system/issues/2528
  test 'link_to with Url drop' do
    url = Liquid::Drops::Url.new('http://example.com/path/to/users', 'Default Title', 'Section')
    assert_equal '<a href="http://example.com/path/to/users">Users</a>', link_to('Users',url)
  end

  test '-.sanitize_options' do
    assert_equal({} , Liquid::Filters::RailsHelpers.sanitize_options({}))
    assert_equal({'foo' => 'bar'} , Liquid::Filters::RailsHelpers.sanitize_options({foo: :bar}))

    options = Liquid::Filters::RailsHelpers.sanitize_options({Object.new => {Object.new => Object.new}})
    assert_kind_of String, options.keys[0]
    assert_kind_of String, options.values[0]
  end

  attr_reader :site_account

  test 'image_tag' do
    default_options = Paperclip::Attachment.default_options
    Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))

    CMS::S3.stubs(:bucket).returns('test')

    file = FactoryBot.create(:cms_file)
    file.attachment = Rails.root.join('test', 'fixtures', 'hypnotoad.jpg').open
    file.save!

    @context = mock(registers: { controller: self })
    @site_account = mock(files: mock(find_by_path: file))

    image = image_tag('hypnotoad.jpg')

    assert_match 'https://test.s3.amazonaws.com', image
  end

  test 'dom_id' do
    alert = Alert.new()
    alert.id = 1
    drop = ::Liquid::Drops::Alert.new(alert)
    assert_equal 'alert_1', dom_id(drop)
  end

  test 'create_button' do
    @context.registers[:controller] = ApplicationController.new

    html = create_button('Title', '/path', 'disable_with' => 'deleting...', 'confirm' => 'sure?', 'class' => 'foo')

    assert_equal '<form class="button_to" method="post" action="/path"><input class="foo" data-confirm="sure?" data-disable-with="deleting..." type="submit" value="Title" /></form>', html
  end
end
