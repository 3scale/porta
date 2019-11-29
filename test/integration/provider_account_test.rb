# -*- coding: utf-8 -*-
require 'test_helper'

class ProviderAccountTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  test 'disable/enable signup' do
    @provider.disable_signup!
    assert ! @provider.reload.signup_enabled?

    @provider.enable_signup!
    assert @provider.reload.signup_enabled?
  end

  test 'deleting provider with builtin pages does not fail' do
    page = @provider.builtin_pages.build
    page.system_name = 'something-unique'
    page.section = @provider.sections.root
    page.save!

    @provider.destroy

    assert_nil Account.providers.find_by_id(@provider.id)
  end

end
