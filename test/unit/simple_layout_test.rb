# -*- coding: utf-8 -*-
require 'test_helper'

class SimpleLayoutTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test '#import - builtin pages' do
    @provider.settings.allow_multiple_applications!
    @provider.settings.allow_service_plans!
    @provider.settings.allow_multiple_services!

    assert SimpleLayout.new(@provider).import!
    assert_equal 2, @provider.layouts.count
    assert_equal 14, @provider.builtin_static_pages.count

    CMS::Builtin::Page::ORIGINAL_PATHS.keys.each do |system_name|
      page = @provider.builtin_pages.find_by_system_name(system_name)

      assert_not_nil page, "Builtin page #{system_name} missing"
      refute_match /translation missing/, page.description,
                      "#{system_name} is missing description"
    end

    CMS::Builtin::Partial.filesystem_templates.keys.each do |system_name|
      page = @provider.builtin_partials.find_by_system_name(system_name)
      assert_not_nil page, "Builtin partial #{system_name} missing"
    end
  end

  test '#import assets' do
    assert SimpleLayout.new(@provider).import_js_and_css!

    [ [ '/javascripts/3scale.js', 'text/javascript', 'javascripts' ],
      [ '/javascripts/jquery.js', 'text/javascript', 'javascripts' ],
      [ '/javascripts/excanvas.compiled.js', 'text/javascript', 'javascripts' ],
      [ '/css/bootstrap.css', 'text/css', 'css' ],
      [ '/css/default.css', 'text/css', 'css']
    ].each do |path,type, section_name|
      page = @provider.pages.find_by_path(path)

      assert_not_nil page, "#{path} not imported"
      assert page.content.presence
      assert_equal type, page.content_type
      assert_equal page.section.title, section_name
    end
  end

  test '#import - partials' do
    assert SimpleLayout.new(@provider).import!

    %w( messages/menu
        applications/form
        field
        shared/pagination ).each do |name|
      assert_not_nil @provider.builtin_partials.find_by_system_name(name)
    end

    assert_not_nil @provider.partials.find_by_system_name('analytics')
  end

  test '#import - error pages and layouts' do
    SimpleLayout.new(@provider).import!

    error_layout = @provider.layouts.find_by_system_name('error')
    not_found_page = @provider.builtin_pages.find_by_system_name('errors/not_found')

    assert_equal error_layout, not_found_page.layout
  end

  test '#import - builtins have content' do
    SimpleLayout.new(@provider).import!

    @provider.builtin_pages.each do |p|
      assert_not_nil p.published, "Page #{p.system_name} has no content"
    end

    @provider.layouts.each do |p|
      assert_not_nil p.published, "Layout #{p.system_name} has no content"
    end
  end

  test '#import_pages!' do
    sl = SimpleLayout.new(@provider)

    sl.import_pages!

    home = @provider.pages.find_by_path('/')
    assert_not_nil home
    assert_not_nil home.content
    assert_not_nil home.layout
    assert_equal 'text/html', home.content_type
    assert_equal true, home.liquid_enabled
  end

  test '#import_images!' do
    sl = SimpleLayout.new(@provider)

    sl.import_images!

    [ '/images/desk.jpg', '/images/plant.jpg', '/images/notes.jpg',
      '/images/mouse.jpg', '/images/powered-by-3scale-dark.png',
      '/images/powered-by-3scale-light.png',
      '/images/powered-by-3scale.png',
      '/favicon.ico' ].each do |path|
      file = @provider.files.find_by_path(path)
      assert_not_nil file, "File #{path} not imported"
      assert_not_nil file.attachment, "File #{path} is empty"
      assert_equal file.section.title, 'images'
    end
  end

  test 'import pages' do
    sl = SimpleLayout.new(@provider)
    sl.import_pages!

    [ '/', '/docs' ].each do |path|
      page = @provider.pages.find_by_path(path)

      assert_not_nil page
      assert_equal 'main_layout', page.layout.system_name
    end
  end

  test 'it imports applications/new if multiple apps are enabled' do
    @provider.settings.allow_multiple_applications!
    assert SimpleLayout.new(@provider).import!
    assert_not_nil @provider.builtin_pages.find_by_system_name('applications/new')
  end
end
