require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

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
    refute metric_two.valid?
    assert_not_nil metric_two.errors[:system_name].presence

    metric_three = FactoryBot.build(:metric, :service => service_two, :system_name => 'frags')
    assert metric_three.valid?
  end

  test 'validate uniqueness of system_name in service scope for a method' do
    service = FactoryBot.create(:service)
    hits = service.metrics.hits
    hits.children.create(system_name: "foo", friendly_name: "bar")
    metric_method = hits.children.build(system_name: "foo", friendly_name: "bar")
    refute metric_method.valid?
    assert metric_method.errors[:system_name].present?
  end

  test 'achieve as deleted' do
    service = FactoryBot.create(:simple_service)
    created_at = Time.utc(2009, 12, 22)
    Timecop.freeze(Time.utc(2009, 12, 22)) { FactoryBot.create(:metric, service: service) }
    metric = service.metrics.last
    metric_id = metric.id

    assert_difference(DeletedObjectEntry.method(:count), +1) { metric.destroy! }
    deleted_object_entry = DeletedObjectEntry.last!
    assert_equal metric_id, deleted_object_entry.object_id
    assert_equal 'Metric', deleted_object_entry.object_type
    assert_equal service.id, deleted_object_entry.owner_id
    assert_equal 'Service', deleted_object_entry.owner_type
  end

  context 'on :destroy' do
    should 'destroy pricing_rules'
    should 'destroy usage_limits'

    should 'not destroy metric if there are some reports'
  end

  should 'create_default! with :hits' do
    service = FactoryBot.create(:service)
    service.metrics.find_by_system_name("hits").delete
    metric = Metric.create_default!(:hits, :service_id => service.id)

    assert_equal 'hits', metric.system_name
    assert_equal 'Hits', metric.friendly_name
    assert_equal 'hit', metric.unit
    assert  metric.default?(:hits)
  end

  should 'return false on default?(:hits) if not hits' do
    service = FactoryBot.create(:service)
    metric = Metric.new(:system_name => 'foos', :friendly_name => 'Foos', :unit => 'foo')
    metric.service = service
    metric.save!

    refute metric.default?(:hits)
  end

  context 'child metric' do
    setup do
      @service = FactoryBot.create(:service)
      @parent_metric = @service.metrics.first
      @child_metric = @parent_metric.children.create!(:system_name => 'articles/create',
                                                      :friendly_name => 'Create an article')
    end

    should 'respond true to child?' do
      assert @child_metric.child?
    end

    should 'have the same unit as the parent metric' do
      assert_equal @parent_metric.unit, @child_metric.unit
    end

    should 'have readonly unit' do
      @child_metric.unit = 'call'
      assert_equal 'hit', @child_metric.unit
    end

    should 'be associated to the same service as parent metric' do
      assert_equal @service, @child_metric.service
    end

    should 'only be child of hits' do
      invalid = @child_metric.children.new(:system_name => 'grandchild', :friendly_name => 'invalid')
      assert invalid.invalid?, "Expected Metric to be invalid"
      assert invalid.errors[:parent_id].present?, "Expected Metric to have error on parent_id"
    end
  end

  context 'metric that is not child' do
    setup { @metric = FactoryBot.create(:metric) }

    should 'respond false to child?' do
      refute @metric.child?
    end
  end

  context 'metric that has children' do
    setup do
      @metric = service = FactoryBot.create(:service).metrics.first
      @metric.children.create!(:friendly_name => 'Foos')
    end

    should 'return true on parent?' do
      assert @metric.parent?
    end
  end

  context 'metric that does not have children' do
    setup { @metric = FactoryBot.create(:metric) }

    should 'return false on parent?' do
      refute @metric.parent?
    end
  end

  should 'return only top-level metric on top_level' do
    service = FactoryBot.create(:service)
    metric_one = FactoryBot.create(:metric, :service => service)
    metric_two = FactoryBot.create(:metric, :service => service)
    metric_three = FactoryBot.create(:metric, :parent => service.metrics.hits, :service => service)

    assert_same_elements [service.metrics.hits, metric_one, metric_two], service.metrics.top_level
  end

  should '.ids_indexed_by_names returns metric ids indexed by names' do
    service = FactoryBot.create(:service)
    metric_1 = FactoryBot.create(:metric, :system_name => 'foo', :service => service)
    metric_2 = FactoryBot.create(:metric, :system_name => 'bar', :service => service)
    metric_3 = FactoryBot.create(:metric, :system_name => 'XoXo', :service => service)
    hits = service.metrics.hits
    assert_equal({'hits' => hits.id, 'foo' => metric_1.id, 'bar' => metric_2.id, 'xoxo' => metric_3.id},
                 service.metrics.ids_indexed_by_names)
  end

  should '.ancestors_ids returns hash of ancestors ids indexed by descendant id' do
    service = FactoryBot.create(:service)
    hits = service.metrics.hits
    child = FactoryBot.create(:metric, :parent => hits, :service => service)

    assert_equal({child.id => [hits.id]},
                 service.metrics.ancestors_ids)
  end

  test '.hits returns metric called hits if it exists' do
    service = FactoryBot.create(:service)
    metric = service.metrics.find_by_system_name("hits")

    assert_equal metric, service.metrics.hits
  end

  test '.hits returns first metric if there is no one called hits' do
    service = FactoryBot.create(:service)
    service.metrics.find_by_system_name("hits").delete
    metric_one = FactoryBot.create(:metric, :system_name => 'foos', :service => service)
    metric_two = FactoryBot.create(:metric, :system_name => 'bars', :service => service)

    assert_equal metric_one, service.metrics.hits
  end

  context 'visibility options for plan' do
    setup do
      @plan =  FactoryBot.create(:application_plan)
      @metric = FactoryBot.create(:metric, :service => @plan.service)
    end

    should 'be visible by default' do
      assert @metric.visible_in_plan?(@plan)
    end

    should 'toggle visibility' do
      assert @metric.visible_in_plan?(@plan)

      @metric.toggle_visible_for_plan(@plan)
      refute @metric.visible_in_plan?(@plan)

      @metric.toggle_visible_for_plan(@plan)
      assert @metric.visible_in_plan?(@plan)
    end

    should 'be limits_only_text by default' do
      assert @metric.limits_only_text_in_plan?(@plan)
    end

    should 'toggle limits_only_text' do
      assert @metric.limits_only_text_in_plan?(@plan)

      @metric.toggle_limits_only_text_for_plan(@plan)
      refute @metric.limits_only_text_in_plan?(@plan)

      @metric.toggle_limits_only_text_for_plan(@plan)
      assert @metric.limits_only_text_in_plan?(@plan)
    end

  end # visibility options for plan

  context 'availability for plan' do
    setup do
      @plan =  FactoryBot.create(:application_plan)
      @metric1 = FactoryBot.create(:metric,  :service => @plan.service)
      @metric2 = FactoryBot.create(:metric,  :service => @plan.service)

      FactoryBot.create :usage_limit, :plan => @plan, :metric => @metric1, :period => :day, :value => 1
      FactoryBot.create :usage_limit, :plan => @plan, :metric => @metric2, :period => :day, :value => 1

      @disabled_plan =  FactoryBot.create(:application_plan)
      FactoryBot.create :usage_limit, :plan => @disabled_plan, :metric => @metric1, :period => :day, :value => 0
      FactoryBot.create :usage_limit, :plan => @disabled_plan, :metric => @metric2, :period => :day, :value => 0
    end

    should 'be enabled for plan if no limit 0 is present' do
      assert @plan.usage_limits.where(metric_id: @metric1.id, value: 0).empty?

      assert @metric1.enabled_for_plan?(@plan)
      refute @metric1.disabled_for_plan?(@plan)
    end

    should 'be disabled for plan if a limit 0 is present' do
      refute @disabled_plan.usage_limits.where(metric_id: @metric1.id, value: 0).empty?

      assert @metric1.disabled_for_plan?(@disabled_plan)
      refute @metric1.enabled_for_plan?(@disabled_plan)
    end

    should 'disable only the given metric' do
      assert @metric1.enabled_for_plan?(@plan)
      assert @metric2.enabled_for_plan?(@plan)

      @metric1.disable_for_plan(@plan)

      assert @metric1.disabled_for_plan?(@plan)
      assert @metric2.enabled_for_plan?(@plan)
    end

    should 'disable the given metric even if usage limit already exists' do
      FactoryBot.create :usage_limit, plan: @plan, metric: @metric1, period: :minute, value: 1

      assert @metric1.enabled_for_plan?(@plan)
      refute @metric1.disabled_for_plan?(@plan)

      @metric1.disable_for_plan(@plan)

      assert @metric1.disabled_for_plan?(@plan)
      refute @metric1.enabled_for_plan?(@plan)
    end

    should 'not disable the given metric - all periods are being used' do
      used_periods = @plan.usage_limits.of_metric(@metric1).pluck(:period).uniq

      (UsageLimit::PERIODS - used_periods.map(&:to_sym)).each do |period|
        FactoryBot.create :usage_limit, plan: @plan, metric: @metric1, period: period, value: 1
      end

      assert @metric1.enabled_for_plan?(@plan)
      refute @metric1.disabled_for_plan?(@plan)
      assert @metric1.errors.blank?

      @metric1.disable_for_plan(@plan)

      assert @metric1.enabled_for_plan?(@plan)
      refute @metric1.disabled_for_plan?(@plan)
      refute @metric1.errors.blank?
    end

    should 'enable only the given metric' do
      assert @metric1.disabled_for_plan?(@disabled_plan)
      assert @metric2.disabled_for_plan?(@disabled_plan)

      @metric1.enable_for_plan(@disabled_plan)

      assert @metric1.enabled_for_plan?(@disabled_plan)
      assert @metric2.disabled_for_plan?(@disabled_plan)
    end

    should 'toggle availability' do
      assert @metric1.enabled_for_plan?(@plan)

      @metric1.disable_for_plan(@plan)
      assert @metric1.disabled_for_plan?(@plan)

      @metric1.enable_for_plan(@plan)
      assert @metric1.enabled_for_plan?(@plan)
    end

  end # enabled or disabled for plan
end
