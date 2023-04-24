# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Account::LogosControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::FileFixtures

  def setup
    @provider = FactoryBot.create(:provider_account)
    provider.settings.allow_branding!
    login! provider
  end

  attr_reader :provider

  test 'update when it should work' do
    assert_change(of: -> { provider.profile.reload.logo_file_name }, from: nil, to: 'hypnotoad.jpg') do
      put provider_admin_account_logo_path, params: { profile: {logo: logo_file} }
    end

    assert_redirected_to edit_provider_admin_account_logo_path
    assert_equal 'The logo was successfully uploaded.', flash[:notice]
    assert_nil flash[:error]

    sizes = %i(large medium thumb invoice).map do |style|
      file = Tempfile.new(["logo-", ".jpg"])
      provider.profile.logo.copy_to_local_file style, file.path
      file.rewind
      FastImage.size(file)
    end
    assert_equal [[300, 239], [150, 120], [100, 80], [63, 50]], sizes
  end

  test 'upload a small logo' do
    put provider_admin_account_logo_path, params: { profile: {logo: small_logo_file} }

    assert_redirected_to edit_provider_admin_account_logo_path
    assert_equal 'The logo was successfully uploaded.', flash[:notice]
    assert_nil flash[:error]

    sizes = %i(large medium thumb invoice).map do |style|
      file = Tempfile.new(["logo-", ".png"])
      provider.profile.logo.copy_to_local_file style, file.path
      file.rewind
      FastImage.size(file)
    end
    assert_equal [[10, 10], [10, 10], [10, 10], [10, 10]], sizes
  end

  test 'update when it should fail' do
    assert_no_change(of: -> { provider.profile.reload.logo_file_name }) do
      put provider_admin_account_logo_path, params: { profile: { logo: fixture_file_upload(file_fixture("small.gif")) } }
    end

    assert_redirected_to edit_provider_admin_account_logo_path
    assert_match /Logo content type invalid/, flash[:error]
    assert_nil flash[:notice]
  end

  test 'update unauthorized without branding switch' do
    provider.settings.deny_branding!

    assert_no_change(of: -> { provider.profile.reload.logo_file_name }) do
      put provider_admin_account_logo_path, params: { profile: { logo: logo_file } }
    end

    assert_response :forbidden
  end

  test 'destroy when it should work' do
    provider.profile.update_attribute(:logo, Rack::Test::UploadedFile.new(logo_file, 'image/jpeg', true))

    assert_change(of: -> { provider.profile.reload.logo_file_name }, from: provider.profile.logo_file_name, to: nil) do
      delete provider_admin_account_logo_path, params: { profile: { logo: logo_file } }
    end

    assert_redirected_to edit_provider_admin_account_logo_path
    assert_equal 'The logo was successfully deleted.', flash[:notice]
    assert_nil flash[:error]
  end

  test 'destroy when it should fail' do
    provider.profile.update(logo: Rack::Test::UploadedFile.new(logo_file, 'image/jpeg', true))
    Profile.any_instance.stubs(valid?: false)
    ActiveModel::Errors.any_instance.stubs(full_messages: ['Error 1st', 'Another Error'])

    assert_no_change(of: -> { provider.profile.reload.logo_file_name }, to: nil) do
      delete provider_admin_account_logo_path, params: { profile: { logo: logo_file } }
    end

    assert_redirected_to edit_provider_admin_account_logo_path
    assert_equal 'Error 1st and Another Error', flash[:error]
    assert_nil flash[:notice]
  end

  test 'destroy unauthorized without branding switch' do
    provider.settings.deny_branding!

    assert_no_change(of: -> { provider.profile.reload.logo_file_name }) do
      delete provider_admin_account_logo_path, params: { profile: { logo: logo_file } }
    end

    assert_response :forbidden
  end

  def logo_file
    @logo_file ||= fixture_file_upload(file_fixture('hypnotoad.jpg'))
  end

  def small_logo_file
    @small_logo_file ||= fixture_file_upload(file_fixture('small.png'))
  end
end
