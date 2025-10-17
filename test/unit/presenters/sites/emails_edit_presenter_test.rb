# frozen_string_literal: true

require 'test_helper'

class Sites::EmailsEditPresenterTest < ActionView::TestCase
  def setup
    super
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:simple_user, account: @provider, role: :admin)
    @service1 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 1')
    @service2 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 2', support_email: 'beta@example.com')
    @service3 = FactoryBot.create(:simple_service, account: @provider, name: 'Service 3')

    @presenter = Sites::EmailsEditPresenter.new(user: @user)
  end

  test 'it has all necessary props' do
    props = @presenter.props
    assert props
    assert_equal I18n.t('sites.emails.edit.add_exception'), props[:buttonLabel]
    assert_equal I18n.t('sites.emails.remove_confirmation'), props[:removeConfirmation]
    assert_same_elements props[:exceptions].pluck(:id), [@service2.id]
    assert_same_elements props[:products].pluck(:id), [@service1.id, @service3.id]
    assert_equal 2, props[:productsCount]
    assert_not_empty props[:productsPath]
  end

  test 'products are paginated to 20 per page' do
    FactoryBot.create_list(:simple_service, 25, account: @provider)

    props = @presenter.props
    assert_equal 20, props[:products].size
    assert_equal 27, props[:productsCount] # 25 + 2 from setup
  end

  test 'products are ordered by name' do
    FactoryBot.create(:simple_service, account: @provider, name: 'Z Service')
    FactoryBot.create(:simple_service, account: @provider, name: 'A Service')
    FactoryBot.create(:simple_service, account: @provider, name: 'M Service')

    props = @presenter.props
    product_names = props[:products].pluck(:name)

    assert_equal 'A Service', product_names.first
    assert product_names.index('M Service') < product_names.index('Z Service')
  end

  test 'only exceptions include support_email in JSON' do
    props = @presenter.props
    assert props[:exceptions].pluck(:supportEmail).all?
    assert props[:products].pluck(:supportEmail).none?
  end

  test 'only accessible services are included' do
    other_provider = FactoryBot.create(:provider_account)
    other_service = FactoryBot.create(:simple_service, account: other_provider,
                                                       name: 'Other Provider Service')

    props = @presenter.props
    product_ids = props[:products].pluck(:id)
    exception_ids = props[:exceptions].pluck(:id)

    assert_not_includes product_ids, other_service.id
    assert_not_includes exception_ids, other_service.id
  end
end
