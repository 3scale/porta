require 'test_helper'

class EndUserTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  subject { @end_user }

  def setup
    @service = Factory(:service)
  end

  context 'blank new end user' do
    subject { EndUser.new nil }

    should 'validate presence of name' do
      subject.valid?
      assert !subject.errors[:username].blank?
    end

    should 'validate presence of service' do
      subject.valid?
      assert !subject.errors[:service].blank?
    end

    should 'validate length of username' do
      subject.username = 'M' * 201

      subject.valid?

      assert subject.errors[:username].to_sentence.include?('is too long')
    end

    should 'validate format of username' do
      subject.username = 'alexander supetramp'
      subject.valid?

      assert subject.errors[:username].to_sentence.include?('is invalid')
    end
  end

  context "new End User" do
    setup do
      @end_user = EndUser.new(@service, :username => 'test-subject')
    end

    should 'be new_record' do
      assert subject.new_record?
    end

    should 'allow changing of plan' do
      plan = Factory(:end_user_plan, :service => @service)
      subject.plan = plan

      assert_equal plan, subject.plan
    end

    should 'not have default plan' do
      assert_nil subject.plan
    end

    should 'not allow to change plan from another service' do
      service = Factory(:service)
      plan = Factory(:end_user_plan, :service => service)

      assert_raise ActiveRecord::RecordNotFound do
        subject.plan = plan
      end
    end

    should 'allow setting of username' do
      assert_equal 'test-subject', subject.username
      subject.attributes = {:username => 'test'}
      assert_equal 'test', subject.username
    end

    should 'not be saved when said so without plan' do
      assert_raise ActiveRecord::RecordInvalid do
        subject.save!
      end
      assert !subject.save
    end

    context 'with plan' do
      setup do
        @plan = Factory(:end_user_plan, :service => @service, :name => 'test-plan')
        @end_user = EndUser.new(@service, :username => 'test-subject')
      end

      should 'save prefixed plan_id' do
        assert_equal subject.attributes[:plan_id], @plan.backend_id

        ThreeScale::Core::User.expects(:save!).with(subject.attributes).returns(true)

        subject.stubs(:uniqueness_of_username) # to prevent a dupe validation error
        assert subject.save!
      end

      should 'have default plan' do
        assert_equal @plan, subject.plan
      end

      context 'and non default plan' do
        setup do
          @default = @plan
          @plan = Factory(:end_user_plan, :service => @service, :name => 'non-default-plan')
          @end_user = EndUser.new(@service, :username => 'test-subject')
        end

        should 'have default plan' do
          assert_equal @default, subject.plan
        end

        should 'save non default when assigned' do
          subject.plan = @plan
          assert_equal @plan, subject.plan
          assert_equal subject.attributes[:plan_name], @plan.name

          ThreeScale::Core::User.expects(:save!).with(subject.attributes).returns(true)

          subject.stubs(:uniqueness_of_username) # to prevent a dupe validation error
          assert subject.save!
        end
      end

    end
  end

  context 'existing End User' do
    setup do
      @plan = Factory(:end_user_plan, :service => @service, :name => 'test-plan')
      end_user = EndUser.new(@service, username: 'test-subject')
      EndUser.stubs(:find).with(@service, 'test-subject').returns(end_user)
      #EndUser::BACKEND_CLASS.save! :username => 'test-subject',
      #:plan_name => @plan.name, :plan_id => @plan.backend_id,
      #:service_id => @service.backend_id
      @end_user = EndUser.find(@service, 'test-subject')
    end

    should 'have unique name' do
       @end_user = EndUser.new(@service, :username => 'test-subject')

       assert subject.invalid?
       assert !subject.errors[:username].blank?

       assert !subject.save
    end

    should 'have right plan' do
      assert_equal @plan, subject.plan
    end

    should 'have right service' do
      assert_equal @plan.service, @service
    end

    should 'have to_param method' do
      assert subject.username, subject.to_param
    end

    should 'not allow setting of username' do
      subject.stubs(:new_record?).returns(false)
      assert_equal 'test-subject', subject.username

      subject.attributes = {:username => 'test'}
      assert_equal 'test-subject', subject.username
    end

    should 'be deleted when called #destroy' do
      ThreeScale::Core::User.expects(:delete!).with(@service.backend_id, subject.username)
      subject.destroy
    end

    context 'with non default plan' do
      setup do
        @service.update_attribute :default_end_user_plan, Factory(:end_user_plan, :service => @service, :name => 'default-plan')
        @end_user = EndUser.find(@service, 'test-subject')
      end

      should 'have right plan' do
        assert_equal @plan, subject.plan
      end
    end
  end

  context 'EndUser#find' do
    should 'return nil when user is not found' do
      assert_nil EndUser.find(@service, 'non-existing-user')
      assert_nil EndUser.find(@service, '')
      assert_nil EndUser.find(@service, nil)
    end
  end


end
