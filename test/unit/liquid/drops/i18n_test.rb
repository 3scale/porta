require 'test_helper'

class Liquid::Drops::I18nDropTest < ActiveSupport::TestCase

  include Liquid

  def setup
    @drop = Drops::I18n.new
    Time.use_zone('UTC') do
      @datetime = Time.mktime(2013, 12, 11, 10, 9, 8)
    end
  end

  test "return short_date" do
    assert_equal 'Dec 11', ::I18n.l(@datetime, format: @drop.short_date)
  end

  test "return long_date" do
    assert_equal("December 11, 2013", ::I18n.l(@datetime, format: @drop.long_date))
  end

  test 'return default_date' do
    assert_equal("2013-12-11", ::I18n.l(@datetime, format: @drop.default_date))
  end

  test 'return default_time' do
    assert_equal("11 Dec 2013 10:09:08 UTC", ::I18n.l(@datetime, format: @drop.default_time))
  end

end
