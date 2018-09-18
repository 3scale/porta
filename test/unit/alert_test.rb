require 'test_helper'

class AlertTest < ActiveSupport::TestCase
  subject { @alert || Alert.new }

  should belong_to(:account)
  should belong_to(:cinstance)

  should validate_presence_of(:utilization)
  should validate_presence_of(:level)
  should validate_numericality_of(:level)
  should validate_numericality_of(:utilization)

  def test_by_level
    FactoryGirl.create(:limit_alert, level: 50)
    FactoryGirl.create(:limit_alert, level: 80)

    alerts = Alert.by_level(80)
    assert_kind_of Alert::ActiveRecord_Relation, alerts
    assert_equal 1, alerts.count
  end

  context 'Alert#kind' do
    should 'should return :alert if its alert' do
      assert_equal :alert, Alert.new(:level => 99).kind
      assert_equal :alert, Alert.new(:level => 0).kind
    end

    should 'should return :violation if its violation' do
      assert_equal :violation, Alert.new(:level => 100).kind
      assert_equal :violation, Alert.new(:level => 300).kind
    end
  end

end
