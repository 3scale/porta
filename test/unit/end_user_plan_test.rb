require 'test_helper'

class EndUserPlanTest < ActiveSupport::TestCase
  subject { @end_user_plan || EndUserPlan.new }

  should belong_to :service

  should have_many(:metrics).through(:service)
  should have_many(:usage_limits).dependent(:destroy)
  should have_many(:plan_metrics).dependent(:destroy)

  should validate_presence_of(:service)
  should validate_presence_of(:name)

  context "End user plan" do
    setup do
      @end_user_plan = FactoryBot.create(:end_user_plan, :service => FactoryBot.create(:service))
    end

    should 'validate name uniqueness' do
      other = @end_user_plan.dup
      assert ! other.valid?
      assert !other.errors[:name].blank?

      other = FactoryBot.create(:end_user_plan, :service => FactoryBot.create(:service), :name => @end_user_plan.name)
      assert other.valid?
    end

    should 'update service after name change' do
      subject.update_attribute :name, 'other name'

      assert 'other name', subject.service.default_end_user_plan.name
    end

    should 'be marked as default if is first for service created' do
      assert_equal subject, subject.service.default_end_user_plan
    end

    should 'should return prefixed backend_id' do
      assert_equal subject.class.prefix_id(subject.id), subject.backend_id
    end

    should 'preserve scope when creating usage limit' do
      metric = subject.service.metrics.create! :friendly_name => 'Bananas', :unit => 'banana'

      limit = subject.usage_limits.create!(:metric => metric, :period => 'day')
      assert_equal subject, limit.plan

      limit = subject.usage_limits.of_metric(metric).create!(:period => 'month')
      assert_equal subject, limit.plan

      limit = metric.usage_limits.of_plan(subject).create!(:period => 'year', :plan => subject)
      assert_equal subject, limit.plan
    end
  end

  context 'EndUserPlan class methods' do
    subject { EndUserPlan }
    setup do
      @prefix = subject::ID_PREFIX
    end

    should 'prefix given id' do
      id = 42
      prefixed = [@prefix, id].join

      assert_equal prefixed, subject.prefix_id(id)
    end

    should 'unprefix given id' do
      id = 42
      prefixed = [@prefix, id].join

      assert_equal id.to_s, subject.unprefix_id(prefixed)
    end

    should 'return nil on empty string' do
      assert_nil subject.unprefix_id('')
    end
  end

end
