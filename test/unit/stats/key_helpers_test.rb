require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::KeyHelpersTest < ActiveSupport::TestCase
  include Stats::KeyHelpers

  test 'key_for with active record' do
    plan = FactoryBot.build_stubbed(:application_plan, :issuer => nil)

    assert_equal "plan:#{plan.id}", key_for(plan)
  end

  test 'key_for with symbol' do
    assert_equal "foo", key_for(:foo)
  end

  test 'key_for with number' do
    assert_equal "125", key_for(125)
  end

  test 'key_for with hash' do
    assert_equal "foo:bar", key_for(:foo => :bar)
  end

  test 'key_for with hash with active record value' do
    plan = FactoryBot.build_stubbed(:application_plan, :issuer => nil)

    assert_equal "foo:#{plan.id}", key_for(:foo => plan)
  end

  test 'key_for with nil' do
    assert_equal "", key_for(nil)
  end

  test 'key_for encodes values' do
    assert_equal "hello+world", key_for('hello world')
  end

  test 'key_for with array' do
    plan = FactoryBot.build_stubbed(:application_plan, :issuer => nil)

    assert_equal "foo/bar/plan:#{plan.id}/day:20091101",
                 key_for(:foo, :bar, plan, :day => '20091101')
  end

  test 'key_for applies key tag' do
    service = FactoryBot.create(:service)

    assert_equal "{service:#{service.backend_id}}", key_for(service)
    assert_equal "{service:#{service.backend_id}}", key_for(:service => service.id)
  end
end
