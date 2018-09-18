require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class FeatureTest < ActiveSupport::TestCase
  test 'sets system_name' do
    feature = Feature.create!(:name => 'The best stuff!!!')
    assert_equal 'the_best_stuff', feature.system_name
    assert_equal feature, Feature.find_by_system_name('the_best_stuff')
  end

  test 'allows to override system_name' do
    feature = Feature.create!(:name => 'SSL Access', :system_name => 'ssl')
    assert_equal 'ssl', feature.system_name
  end

  test 'sets system_name if it is blank' do
    feature = Feature.create!(:name => 'SSL Access', :system_name => '')
    assert_equal 'ssl_access', feature.system_name
  end

  test 'is created as visible by default' do
    feature = Feature.create!(:name => 'SSL Access')
    assert feature.visible?
  end

  test 'can be hidden' do
    feature = Feature.new(:name => 'SSL Access')
    feature.visible = false
    feature.save!

    assert !feature.visible?
  end

  test 'Feature.visible returns only visible features' do
    feature_one = Feature.create!(:name => 'SSL Access')
    feature_two = Feature.create!(:name => 'Replication', :visible => false)

    assert_contains         Feature.visible, feature_one
    assert_does_not_contain Feature.visible, feature_two
  end
end
