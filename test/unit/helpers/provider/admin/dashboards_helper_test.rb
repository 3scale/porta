require 'test_helper'

class Provider::Admin::DashboardsHelperTest < ActionView::TestCase
  include Provider::Admin::DashboardsHelper

  def setup
    stubs(icon: '<i></i>')
  end
  
  test 'dashboard_navigation_link creates basic link' do
    assert_equal '<a class="DashboardNavigation-link" href="/path">Link</a>',
      dashboard_navigation_link('Link', '/path')
  end
  
  test 'dashboard_navigation_link can add an icon using options' do
    assert_equal '<a class="DashboardNavigation-link" href="/path">Link <i></i></a>',
      dashboard_navigation_link('Link', '/path', { icon_name: 'foo', icon_append_name: true })
  end

  test 'dashboard_navigation_link can highlight link using options' do
    assert_equal '<a class="DashboardNavigation-link u-notice" href="/path">Link</a>',
      dashboard_navigation_link('Link', '/path', { notice: 'true' })
  end

  test 'dashboard_collection_link creates pluralized link' do
    assert_equal '<a class="DashboardNavigation-link" href="/path">1 Number</a>',
      dashboard_collection_link('Number', [1], '/path')

    assert_equal '<a class="DashboardNavigation-link" href="/path">2 Numbers</a>',
      dashboard_collection_link('Number', [1,2], '/path')
  end

  test 'dashboard_collection_link can use custom plural' do
    assert_equal '<a class="DashboardNavigation-link" href="/path">2 Plural</a>',
      dashboard_collection_link('Singular', [1,2], '/path', { plural: 'Plural' })
  end

  test 'dashboard_network_link and dashboard_navigation_link are equivalent' do
    navigation_link = dashboard_navigation_link('1 Number', '/path')
    collection_link = dashboard_collection_link('Number', [1], '/path')

    assert_equal navigation_link, collection_link

    navigation_link = dashboard_navigation_link('2 Numbers', '/path')
    collection_link = dashboard_collection_link('Number', [1,2], '/path')

    assert_equal navigation_link, collection_link
  end

  test 'safe_wrap_with_parenthesis should wrap link in parenthesis and return a safe html' do
    link = '<a href="/foo">I am safe!</a>'
    safe_link = safe_wrap_with_parenthesis(link)
    assert " (#{link.html_safe})", safe_link
    assert safe_link.html_safe?
  end

end