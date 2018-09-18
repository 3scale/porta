require 'test_helper'

class ReferrerFiltersTest < ActiveSupport::TestCase
  include TestHelpers::FakeWeb

  disable_transactional_fixtures!

  subject { @referrer_filter ||= Factory(:referrer_filter) }

  def setup
    ReferrerFilter.disable_backend!
  end

  should 'have immutable value' do
    assert_raise(ActiveRecord::ActiveRecordError) do
      subject.update_attribute :value, 'another'
    end
  end

  context 'referrer_filters' do

    setup do
      @application = Factory(:cinstance)
      @referrer_filters = @application.referrer_filters
    end

    should 'add filters' do
      assert_equal 0, @referrer_filters.size

      assert @referrer_filters.add('whatever').persisted?
      # should validate uniqueness
      refute @referrer_filters.add('whatever').persisted?

      assert_equal 1, @referrer_filters.size
    end

    should 'validate format of value' do
      ReferrerFilter.any_instance.stubs(:keys_limit_reached).returns({})

      # valid
      ['example.net', '73.170.78.2', 'foo-bar.example.net', 'example.*',
       '*.example.com', 'west-is-123.the.best', 'example.example.org'].each do |value|

        assert @referrer_filters.add(value).persisted?, "'#{value}' is valid"
      end

      # invalid
      ['@example.net', 'example.net:80', '+73.170.78.2', ' 73.170.78.2',
       'example.net?query=s', 'http://example.org', '73.170.78.2 '].each do |value|

        refute @referrer_filters.add(value).persisted?, "'#{value}' is invalid"
      end
    end

    should 'return list of values' do
      assert @referrer_filters.add('some-key')
      assert_equal ['some-key'], @referrer_filters.pluck_values
    end

    should 'raise when removing unknown value' do
      assert_raise(ActiveRecord::RecordNotFound) do
        @referrer_filters.remove('unknown')
      end
    end

    should 'remove key' do
      key = Factory(:referrer_filter, :application => @application)
      assert_equal [key], @application.referrer_filters(true)
      assert @application.referrer_filters.remove(key.value)
      assert_equal [], @application.referrer_filters
    end

    should 'limit number of keys' do
      ReferrerFilter::REFERRER_FILTERS_LIMIT.times do |n|
        assert @referrer_filters.add("filter-#{n+1}").persisted?
      end

      # REFERRER_FILTERS_LIMIT + 1 is over the limit
      # TODO: maybe check for raise?
      referrer_filter = @referrer_filters.add('limit-reached')
      refute referrer_filter.persisted?

      refute_match(/translation missing/, referrer_filter.errors[:base].to_sentence)
    end

    should 'update backend' do
      ReferrerFilter.enable_backend!

      expect_backend_create_referrer_filter(@application, 'some-key')
      @referrer_filters.add('some-key')

      expect_backend_delete_referrer_filter(@application, 'some-key')
      @referrer_filters.remove('some-key')
    end

    should 'delete filters when app is deleted' do
      @referrer_filters.add('some-key')

      @application.reload

      ReferrerFilter.enable_backend!
      expect_backend_delete_referrer_filter(@application, 'some-key')

      @application.destroy
    end
  end
end
