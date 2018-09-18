require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  should have_db_column :logo_file_name
  should have_db_column :logo_content_type
  should have_db_column :logo_file_size

  should validate_presence_of :company_size

  context '#account attribute validation' do
    setup do
      @invalid_profile = Factory.build(:profile, :account_id => nil)
    end

    should 'not be saved without account' do
      #this complex tests are used because if we try to save with account_id == nil
      # a mysql ActiveRecord::StatementInvalid exception is raised
      assert_nothing_raised { @invalid_profile.save }
      assert_equal false, @invalid_profile.save
    end
  end

  context 'initialization' do
    setup do
      @profile = Factory(:profile)
    end

    should 'create profile in private state' do
      assert_equal 'private', @profile.state
    end
  end

  test '.model_name.human is Profile' do
    assert Profile.model_name.human == "Account profile"
  end

  context 'customers_type field' do
    setup do
      @profile = Factory(:profile, :customers_type => ["item"])
    end

    should 'be serialized as an array' do
      assert_equal @profile.customers_type, ["item"]
    end
  end

  context '.published class method' do
    setup do
      @profile = Factory(:profile)
      @profile.update_attribute(:state, 'published')

      @profile_unpublished = Factory(:profile)
      @profile_unpublished.update_attribute(:state, 'private')
    end

    should 'return only published profiles' do
      published_profiles = Profile.published

      assert  published_profiles.include?(@profile)
      assert !published_profiles.include?(@profile_unpublished)
    end
  end

  context 'with individual or company profiles' do
    setup do
      @individual_profile = Factory
        .build(:profile, :company_size => Profile::IndividualNotCompany)
      @company_profile = Factory
        .build(:profile, :company_size => Profile::CompanySizes.last)
    end

    context '#company_type validation' do

      context 'a profile of an individual' do
        setup { @individual_profile.company_type = nil }

        should 'be valid without company_type' do
          assert @individual_profile.valid?
        end
      end

      context 'a profile of a company' do
        setup { @company_profile.company_type = nil }

        should 'not be valid without company_type' do
          assert_equal false, @company_profile.valid?
          assert_equal false, @company_profile.errors[:company_type].empty?
        end
      end

    end

    context '#individual_profile? method' do
      should 'return true for individual profiles' do
        assert @individual_profile.individual_profile?
      end

      should 'return false for company profiles' do
        assert_equal false, @company_profile.individual_profile?
      end

      should 'return false for profiles with company_size set to nil' do
        profile = Profile.new
        profile.company_size = nil

        assert_equal false, profile.individual_profile?
      end

      should 'return false for profiles with company_size set to blank' do
        assert_equal false, Profile.new(:company_size => "").individual_profile?
      end
    end

    context '#company_profile? method' do
      should 'return true for company profiles' do
        assert @company_profile.company_profile?
      end

      should 'return false for individual profiles' do
        assert_equal false, @individual_profile.company_profile?
      end

      should 'return false for profiles with company_size set to nil' do
        assert_equal false, Profile.new.company_profile?
      end

      should 'return false for profiles with company_size set to blank' do
        assert_equal false, Profile.new(:company_size => "").company_profile?
      end
    end
  end

  class LogoTest < ActiveSupport::TestCase

    def setup
      default_options = Paperclip::Attachment.default_options
      Paperclip::Attachment.stubs(default_options: default_options.merge(storage: :s3))
    end

    def test_logo_upload
      profile = FactoryGirl.create(:profile)
      hypnotoad = Rails.root.join('test', 'fixtures', 'hypnotoad.jpg').open

      profile.logo = hypnotoad
      profile.logo.s3_interface.client.stub_responses(:put_object, ->(request) {
        assert_equal 'public-read', request.params[:acl]
      })
      profile.save!

      assert profile.logo
    end
  end
end
