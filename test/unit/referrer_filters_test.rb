# frozen_string_literal: true

require 'test_helper'

class ReferrerFiltersTest < ActiveSupport::TestCase
  def setup
    ReferrerFilter.disable_backend!

    @application = FactoryBot.create(:cinstance)
    @referrer_filters = @application.referrer_filters
  end

  test 'have immutable value' do
    assert_raise(ActiveRecord::ActiveRecordError) do
      FactoryBot.create(:referrer_filter).update_attribute(:value, 'another') # rubocop:disable Rails/SkipsModelValidations
    end
  end

  test 'archive_as_deleted' do
    application = FactoryBot.create(:simple_cinstance)

    referrer_filter = FactoryBot.create(:referrer_filter, application: application)
    assert_no_difference(DeletedObject.referrer_filters.method(:count)) { referrer_filter.destroy! }

    referrer_filter = FactoryBot.create(:referrer_filter, application: application)
    referrer_filter.stubs(destroyed_by_association: true)
    assert_difference(DeletedObject.referrer_filters.method(:count)) { referrer_filter.destroy! }
    assert_equal referrer_filter.id, DeletedObject.referrer_filters.last!.object_id
  end

  test 'add filters' do
    assert_equal 0, @referrer_filters.size

    assert @referrer_filters.add('whatever').persisted?
    assert_not @referrer_filters.add('whatever').persisted?

    assert_equal 1, @referrer_filters.size
  end

  test 'validate format of value' do
    ReferrerFilter.any_instance.stubs(:keys_limit_reached).returns({})

    valid = ['example.net', '73.170.78.2', 'foo-bar.example.net', 'example.*', '*.example.com', 'west-is-123.the.best', 'example.example.org']
    valid.each do |value|
      assert @referrer_filters.add(value).persisted?, "'#{value}' is valid"
    end

    invalid = ['@example.net', 'example.net:80', '+73.170.78.2', ' 73.170.78.2', 'example.net?query=s', 'http://example.org', '73.170.78.2 ']
    invalid.each do |value|
      assert_not @referrer_filters.add(value).persisted?, "'#{value}' is invalid"
    end
  end

  test 'return list of values' do
    assert @referrer_filters.add('some-key')
    assert_equal ['some-key'], @referrer_filters.pluck_values
  end

  test 'raise when removing unknown value' do
    assert_raise(ActiveRecord::RecordNotFound) do
      @referrer_filters.remove('unknown')
    end
  end

  test 'remove key' do
    key = FactoryBot.create(:referrer_filter, application: @application)
    assert_equal [key], @application.referrer_filters.reload
    assert @application.referrer_filters.remove(key.value)
    assert_equal [], @application.referrer_filters
  end

  test 'limit number of keys' do
    ReferrerFilter::REFERRER_FILTERS_LIMIT.times do |n|
      assert @referrer_filters.add("filter-#{n+1}").persisted?
    end

    # REFERRER_FILTERS_LIMIT + 1 is over the limit
    # TODO: maybe check for raise?
    referrer_filter = @referrer_filters.add('limit-reached')
    assert_not referrer_filter.persisted?

    assert_no_match(/translation missing/, referrer_filter.errors[:base].to_sentence)
  end

  test 'update backend' do
    ReferrerFilter.enable_backend!

    expect_backend_create_referrer_filter(@application, 'some-key')
    @referrer_filters.add('some-key')

    expect_backend_delete_referrer_filter(@application, 'some-key')
    @referrer_filters.remove('some-key')
  end
end
