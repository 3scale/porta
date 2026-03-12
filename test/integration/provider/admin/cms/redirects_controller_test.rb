# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::CMS::RedirectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
  end

  attr_reader :provider

  test 'index lists all redirects' do
    provider.redirects.create!(source: '/one/from', target: '/one/to')
    provider.redirects.create!(source: '/two/from', target: '/two/to')

    get provider_admin_cms_redirects_path
    assert_response :success

    page = Nokogiri::HTML4::Document.parse(response.body)
    rows = page.xpath('//tbody[@role="rowgroup"]/tr[@role="row"]')
    assert_equal 2, rows.size

    from_values = page.xpath('//td[@data-label="From"]/a').map { |a| a.text.strip }
    to_values = page.xpath('//td[@data-label="To"]').map { |td| td.text.strip }

    assert_same_elements %w[/one/from /two/from], from_values
    assert_same_elements %w[/one/to /two/to], to_values
  end

  test 'create a new redirect' do
    assert_empty provider.redirects
    assert_difference 'CMS::Redirect.count', 1 do
      post provider_admin_cms_redirects_path, params: {
        cms_redirect: {
          source: '/source',
          target: '/target'
        }
      }
    end

    assert_redirected_to provider_admin_cms_redirects_path
    assert_equal 'Redirect created', flash[:success]

    redirect = provider.redirects.first
    assert_equal '/source', redirect.source
    assert_equal '/target', redirect.target
  end

  test 'update a redirect' do
    redirect = provider.redirects.create!(source: '/from', target: '/to')

    put provider_admin_cms_redirect_path(redirect), params: {
      cms_redirect: {
        source: '/new-from',
        target: '/new-to'
      }
    }

    assert_redirected_to provider_admin_cms_redirects_path
    redirect.reload

    assert_equal '/new-from', redirect.source
    assert_equal '/new-to', redirect.target
  end

  test 'delete redirect' do
    redirect = provider.redirects.create!(source: '/from', target: '/to')
    assert_equal 1, provider.redirects.count

    assert_difference 'CMS::Redirect.count', -1 do
      delete provider_admin_cms_redirect_path(redirect)
    end

    assert_redirected_to provider_admin_cms_redirects_path
    assert_equal 0, provider.redirects.count
  end
end