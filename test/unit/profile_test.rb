# frozen_string_literal: true

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  should have_db_column :logo_file_name
  should have_db_column :logo_content_type
  should have_db_column :logo_file_size

  should validate_presence_of :company_size

  should validate_attachment_content_type(:logo)
             .allowing('image/png', 'image/gif', 'image/jpeg')
             .rejecting('image/svg', 'text/plain', 'text/xml', 'image/abc', 'some_image/png')

  test '#account attribute validation: not be saved without account' do
    invalid_profile = FactoryBot.build(:profile, :account_id => nil)
    #this complex tests are used because if we try to save with account_id == nil
    # a mysql ActiveRecord::StatementInvalid exception is raised
    assert_nothing_raised { invalid_profile.save }
    assert_equal false, invalid_profile.save
  end

  test 'initialization: create profile in private state' do
    profile = FactoryBot.create(:profile)
    assert_equal 'private', profile.state
  end

  test '.model_name.human is Profile' do
    assert_equal 'Account profile', Profile.model_name.human
  end

  test 'customers_type field: be serialized as an array' do
    profile = FactoryBot.create(:profile, customers_type: ["item"])
    assert_equal ["item"], profile.customers_type
  end

  test '.published class method: return only published profiles' do
    profile = FactoryBot.create(:profile)
    profile.update(state: 'published')

    profile_unpublished = FactoryBot.create(:profile)
    profile_unpublished.update(state: 'private')
    published_profiles = Profile.published

    assert_includes published_profiles, profile
    assert_not_includes published_profiles, profile_unpublished
  end

  test 'a profile of an individual should be valid without company_type' do
    individual_profile = FactoryBot.create(:profile, company_size: Profile::IndividualNotCompany, company_type: nil)
    assert_valid individual_profile
  end

  test 'a profile of a company should not be valid without company_type' do
    company_profile = FactoryBot.build(:profile, company_size: Profile::CompanySizes.last, company_type: nil)
    assert_not company_profile.valid?
    assert_not_empty company_profile.errors[:company_type]
  end

  test '#individual_profile? method should return true for individual profiles' do
    individual_profile = FactoryBot.create(:profile, company_size: Profile::IndividualNotCompany)
    assert individual_profile.individual_profile?
  end

  test '#individual_profile? method should return false for company profiles' do
    company_profile = FactoryBot.build(:profile, company_size: Profile::CompanySizes.last)
    assert_not company_profile.individual_profile?
  end

  test '#individual_profile? method should return false for profiles with company_size set to nil' do
    # TODO: validation says company_size can't be blank, so is this test necessary/valid?
    profile = Profile.new
    profile.company_size = nil

    assert_not profile.individual_profile?
    # assert_not Profile.new(company_size: nil).individual_profile?
  end

  test '#individual_profile? method should return false for profiles with company_size set to blank' do
    # TODO: validation says company_size can't be blank, so is this test necessary/valid?
    assert_not Profile.new(company_size: '').individual_profile?
  end

  test '#company_profile? method should return true for company profiles' do
    company_profile = FactoryBot.build(:profile, company_size: Profile::CompanySizes.last)
    assert company_profile.company_profile?
  end

  test '#company_profile? method should return false for individual profiles' do
    individual_profile = FactoryBot.create(:profile, company_size: Profile::IndividualNotCompany)
    assert_not individual_profile.company_profile?
  end

  test '#company_profile? method should return false for profiles with company_size set to nil' do
    assert_not Profile.new.company_profile?
  end

  test '#company_profile? method: return false for profiles with company_size set to blank' do
    assert_not Profile.new(company_size: '').company_profile?
  end

  class LogoTest < ActiveSupport::TestCase
    def setup
      default_options = Paperclip::Attachment.default_options
      Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))
    end

    def test_logo_upload
      profile = FactoryBot.create(:profile)
      hypnotoad = Rails.root.join('test/fixtures/hypnotoad.jpg').open

      profile.logo = hypnotoad
      profile.logo.s3_interface.client.stub_responses(:put_object, ->(request) {
        assert_equal 'public-read', request.params[:acl]
      })
      profile.save!

      assert profile.logo
    end

    test 'does not accept a fake image' do
      profile = FactoryBot.build(:profile)

      profile.logo = Rails.root.join('test/fixtures/fake_image.jpg').open

      assert_not profile.valid?
      assert_includes profile.errors[:logo], 'has contents that are not what they are reported to be'
    end
  end
end
