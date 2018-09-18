require 'test_helper'

class CMS::HandlerTest < ActiveSupport::TestCase

  test 'renderer should render page text' do
    template = mock('template', :render => 'Some text')
    handler = CMS::Handler.new(nil).renders(template)
    assert_equal 'Some text', handler.render
  end

  test 'renderer should render markdown html' do
    template = mock('template', :render => '# Some text')
    handler = CMS::Handler.new(:markdown).renders(template)
    assert_equal "<h1>Some text</h1>\n", handler.render
  end

  test 'renderer should render textile html' do
    template = mock('template', :render => 'h1. Some text')
    handler = CMS::Handler.new(:textile).renders(template)
    assert_equal '<h1>Some text</h1>', handler.render
  end

  test 'render blank markdown html' do
    template = mock('template', render: nil)
    handler  = CMS::Handler.new(:markdown).renders(template)

    assert_equal '', handler.render
  end
end
