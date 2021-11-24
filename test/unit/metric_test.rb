# frozen_string_literal: true

require 'test_helper'

class MetricTest < ActiveSupport::TestCase
  should belong_to :service
  should have_many(:pricing_rules).dependent(:destroy)
  should have_many(:usage_limits).dependent(:destroy)

  should have_many :children
  should belong_to :parent

  should validate_presence_of :unit

  should_not allow_value('hellow world').for(:system_name)
  should_not allow_value('hello!').for(:system_name)

  def test_destroyable?
    service = FactoryBot.create(:simple_service)
    metric  = service.metrics.hits

    assert metric

    metric.destroy

    assert metric.reload

    metric.expects(:destroyed_by_association).returns(service)

    metric.destroy

    assert_raise(ActiveRecord::RecordNotFound) { metric.reload }
  end

  test 'index uniq of system_name in service scope' do
    service = FactoryBot.create(:service)
    FactoryBot.create(:metric, :service => service, :system_name => 'frags')
    metric_two = FactoryBot.create(:metric, :service => service)
    assert_raise ActiveRecord::RecordNotUnique do
      metric_two.update_column(:system_name, 'frags')
    end
  end

  test 'index uniq of system_name in owner scope' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api)
    owners = [service, service.backend_api]
    owners.each do |owner|
      owner_attributes = { service: (owner.is_a?(Service) ? owner : nil), owner: owner }
      metric_one = FactoryBot.create(:metric, **owner_attributes, system_name: 'frags')
      metric_two = FactoryBot.create(:metric, owner_attributes)
      assert_not metric_two.update(system_name: 'frags')
      assert_match /already been taken/, metric_two.errors[:system_name].to_s
    end
  end

  test 'system_name is not case sensitive' do
    service = FactoryBot.create(:simple_service)

    metric_one = FactoryBot.create(:metric, service: service, system_name: 'frags')
    metric_two = FactoryBot.create(:metric, service: service)

    assert metric_two.update_column(:system_name, 'Frags')
  end

  # This should be tested by system_name plugin
  test 'validate uniqueness of system_name in service scope' do
    service_one = FactoryBot.create(:service)
    service_two = FactoryBot.create(:service)

    FactoryBot.create(:metric, :service => service_one, :system_name => 'frags')

    metric_two = FactoryBot.build(:metric, :service => service_one, :system_name => 'frags')
    assert_not metric_two.valid?
    assert_not_nil metric_two.errors[:system_name].presence

    metric_three = FactoryBot.build(:metric, :service => service_two, :system_name => 'frags')
    assert metric_three.valid?
  end

  test 'validate uniqueness of system_name in service scope for a method' do
    service = FactoryBot.create(:service)
    hits = service.metrics.hits
    hits.children.create(system_name: "foo", friendly_name: "bar")
    metric_method = hits.children.build(system_name: "foo", friendly_name: "bar")
    assert_not metric_method.valid?
    assert metric_method.errors[:system_name].present?
  end

  test 'fill owner' do
    service = FactoryBot.create(:simple_service)
    service_metric = FactoryBot.build(:metric, service: service)
    assert_not service_metric.owner
    assert service_metric.valid?
    assert_equal service, service_metric.owner

    backend_api = FactoryBot.create(:backend_api, name: 'API', system_name: 'api', account: service.provider)
    backend_metric = FactoryBot.build(:metric, owner: backend_api)
    assert_equal backend_api, backend_metric.owner
    assert backend_metric.valid?
  end

  test 'fill same owner as the parent' do
    backend_api = FactoryBot.create(:backend_api)
    hits = backend_api.metrics.hits
    method = hits.children.create(system_name: 'meth1')
    assert_equal backend_api, method.owner
  end

  pending_test 'on :destroy, destroy pricing_rules'
  pending_test 'on :destroy, destroy usage_limits'
  pending_test 'on :destroy, not destroy metric if there are some reports'

  test 'create_default! with :hits' do
    service = FactoryBot.create(:service)
    service.metrics.find_by(system_name: "hits").delete
    metric = Metric.create_default!(:hits, :service_id => service.id)

    assert_equal 'hits', metric.system_name
    assert_equal 'Hits', metric.friendly_name
    assert_equal 'hit', metric.unit
    assert  metric.default?(:hits)
  end

  test 'return false on default?(:hits) if not hits' do
    service = FactoryBot.create(:service)
    metric = Metric.new(:system_name => 'foos', :friendly_name => 'Foos', :unit => 'foo')
    metric.service = service
    metric.save!

    assert_not metric.default?(:hits)
  end

  test '#hits?' do
    service = FactoryBot.create(:service)

    hits_metric = service.metrics.hits
    non_hits_metric = FactoryBot.create(:metric, owner: service, system_name: 'non-hits')

    assert hits_metric.hits?
    assert_not non_hits_metric.hits?
  end

  test 'respond false to child?' do
    @metric = FactoryBot.create(:metric)
    assert_not @metric.child?
  end

  test 'return true on parent?' do
    @metric = service = FactoryBot.create(:service).metrics.first
    @metric.children.create!(:friendly_name => 'Foos')
    assert @metric.parent?
  end

  test 'return false on parent?' do
    @metric = FactoryBot.create(:metric)
    assert_not @metric.parent?
  end

  test 'return only top-level metric on top_level' do
    service = FactoryBot.create(:service)
    metric_one = FactoryBot.create(:metric, :service => service)
    metric_two = FactoryBot.create(:metric, :service => service)
    metric_three = FactoryBot.create(:metric, :parent => service.metrics.hits, :service => service)

    assert_same_elements [service.metrics.hits, metric_one, metric_two], service.metrics.top_level
  end

  test '.ids_indexed_by_names returns metric ids indexed by names' do
    service = FactoryBot.create(:service)
    metric_1 = FactoryBot.create(:metric, :system_name => 'foo', :service => service)
    metric_2 = FactoryBot.create(:metric, :system_name => 'bar', :service => service)
    metric_3 = FactoryBot.create(:metric, :system_name => 'XoXo', :service => service)
    hits = service.metrics.hits
    assert_equal({'hits' => hits.id, 'foo' => metric_1.id, 'bar' => metric_2.id, 'xoxo' => metric_3.id},
                 service.metrics.ids_indexed_by_names)
  end

  test '.ancestors_ids returns hash of ancestors ids indexed by descendant id' do
    service = FactoryBot.create(:service)
    hits = service.metrics.hits
    child = FactoryBot.create(:metric, :parent => hits, :service => service)

    assert_equal({child.id => [hits.id]},
                 service.metrics.ancestors_ids)
  end

  test '.hits returns metric called hits if it exists' do
    service = FactoryBot.create(:service)
    metric = service.metrics.find_by(system_name: "hits")

    assert_equal metric, service.metrics.hits
  end

  test '.hits returns first metric if there is no one called hits' do
    service = FactoryBot.create(:service)
    service.metrics.find_by(system_name: "hits").delete
    metric_one = FactoryBot.create(:metric, :system_name => 'foos', :service => service)
    metric_two = FactoryBot.create(:metric, :system_name => 'bars', :service => service)

    assert_equal metric_one, service.metrics.hits
  end

  test '.by_provider' do
    provider, other_provider = FactoryBot.create_list(:simple_provider, 2)

    service = FactoryBot.create(:simple_service, account: provider)
    backend_api = FactoryBot.create(:backend_api, account: provider)
    service_metric = FactoryBot.create(:metric, owner: service)
    backend_metric = FactoryBot.create(:metric, owner: backend_api)

    other_service = FactoryBot.create(:simple_service, account: other_provider)
    other_backend_api = FactoryBot.create(:backend_api, account: other_provider)
    other_service_metric = FactoryBot.create(:metric, owner: other_service)
    other_backend_metric = FactoryBot.create(:metric, owner: other_backend_api)

    assert_same_elements [service.metrics.hits, service_metric, backend_api.metrics.hits, backend_metric], Metric.by_provider(provider)
  end
end

class ChildMetricTest < ActiveSupport::TestCase
  def setup
    @service = FactoryBot.create(:service)
    @parent_metric = @service.metrics.first
    @child_metric = @parent_metric.children.create!(:system_name => 'articles/create',
                                                    :friendly_name => 'Create an article')
  end

  test 'respond true to child?' do
    assert @child_metric.child?
  end

  test 'have the same unit as the parent metric' do
    assert_equal @parent_metric.unit, @child_metric.unit
  end

  test 'have readonly unit' do
    @child_metric.unit = 'call'
    assert_equal 'hit', @child_metric.unit
  end

  test 'be associated to the same service as parent metric' do
    assert_equal @service, @child_metric.service
  end

  test 'only be child of hits' do
    invalid = @child_metric.children.new(:system_name => 'grandchild', :friendly_name => 'invalid')
    assert invalid.invalid?, "Expected Metric to be invalid"
    assert invalid.errors[:parent_id].present?, "Expected Metric to have error on parent_id"
  end
end

class VisibilityOptionsForPlanTest < ActiveSupport::TestCase
  def setup
    @plan =  FactoryBot.create(:application_plan)
    @metric = FactoryBot.create(:metric, :service => @plan.service)
  end

  test 'be visible by default' do
    assert @metric.visible_in_plan?(@plan)
  end

  test 'toggle visibility' do
    assert @metric.visible_in_plan?(@plan)

    @metric.toggle_visible_for_plan(@plan)
    assert_not @metric.visible_in_plan?(@plan)

    @metric.toggle_visible_for_plan(@plan)
    assert @metric.visible_in_plan?(@plan)
  end

  test 'be limits_only_text by default' do
    assert @metric.limits_only_text_in_plan?(@plan)
  end

  test 'toggle limits_only_text' do
    assert @metric.limits_only_text_in_plan?(@plan)

    @metric.toggle_limits_only_text_for_plan(@plan)
    assert_not @metric.limits_only_text_in_plan?(@plan)

    @metric.toggle_limits_only_text_for_plan(@plan)
    assert @metric.limits_only_text_in_plan?(@plan)
  end
end

class AvailabilityForPlanTest < ActiveSupport::TestCase
  def setup
    @plan =  FactoryBot.create(:application_plan)
    @metric1 = FactoryBot.create(:metric,  :service => @plan.service)
    @metric2 = FactoryBot.create(:metric,  :service => @plan.service)

    FactoryBot.create :usage_limit, :plan => @plan, :metric => @metric1, :period => :day, :value => 1
    FactoryBot.create :usage_limit, :plan => @plan, :metric => @metric2, :period => :day, :value => 1

    @disabled_plan =  FactoryBot.create(:application_plan)
    FactoryBot.create :usage_limit, :plan => @disabled_plan, :metric => @metric1, :period => :day, :value => 0
    FactoryBot.create :usage_limit, :plan => @disabled_plan, :metric => @metric2, :period => :day, :value => 0
  end

  test 'be enabled for plan if no limit 0 is present' do
    assert @plan.usage_limits.where(metric_id: @metric1.id, value: 0).empty?

    assert @metric1.enabled_for_plan?(@plan)
    assert_not @metric1.disabled_for_plan?(@plan)
  end

  test 'be disabled for plan if a limit 0 is present' do
    assert_not @disabled_plan.usage_limits.where(metric_id: @metric1.id, value: 0).empty?

    assert @metric1.disabled_for_plan?(@disabled_plan)
    assert_not @metric1.enabled_for_plan?(@disabled_plan)
  end

  test 'disable only the given metric' do
    assert @metric1.enabled_for_plan?(@plan)
    assert @metric2.enabled_for_plan?(@plan)

    @metric1.disable_for_plan(@plan)

    assert @metric1.disabled_for_plan?(@plan)
    assert @metric2.enabled_for_plan?(@plan)
  end

  test 'disable the given metric even if usage limit already exists' do
    FactoryBot.create :usage_limit, plan: @plan, metric: @metric1, period: :minute, value: 1

    assert @metric1.enabled_for_plan?(@plan)
    assert_not @metric1.disabled_for_plan?(@plan)

    @metric1.disable_for_plan(@plan)

    assert @metric1.disabled_for_plan?(@plan)
    assert_not @metric1.enabled_for_plan?(@plan)
  end

  test 'not disable the given metric - all periods are being used' do
    used_periods = @plan.usage_limits.of_metric(@metric1).pluck(:period).uniq

    (UsageLimit::PERIODS - used_periods.map(&:to_sym)).each do |period|
      FactoryBot.create :usage_limit, plan: @plan, metric: @metric1, period: period, value: 1
    end

    assert @metric1.enabled_for_plan?(@plan)
    assert_not @metric1.disabled_for_plan?(@plan)
    assert @metric1.errors.blank?

    @metric1.disable_for_plan(@plan)

    assert @metric1.enabled_for_plan?(@plan)
    assert_not @metric1.disabled_for_plan?(@plan)
    assert_not @metric1.errors.blank?
  end

  test 'enable only the given metric' do
    assert @metric1.disabled_for_plan?(@disabled_plan)
    assert @metric2.disabled_for_plan?(@disabled_plan)

    @metric1.enable_for_plan(@disabled_plan)

    assert @metric1.enabled_for_plan?(@disabled_plan)
    assert @metric2.disabled_for_plan?(@disabled_plan)
  end

  test 'toggle availability' do
    assert @metric1.enabled_for_plan?(@plan)

    @metric1.disable_for_plan(@plan)
    assert @metric1.disabled_for_plan?(@plan)

    @metric1.enable_for_plan(@plan)
    assert @metric1.enabled_for_plan?(@plan)
  end
end
