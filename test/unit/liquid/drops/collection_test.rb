require 'test_helper'

class Liquid::Drops::CollectionTest < ActiveSupport::TestCase

  def setup
    @plans = [ FactoryBot.create(:application_plan, system_name: 'my_plan') ]
  end

  test 'indexable by system_name' do
    collection = Liquid::Drops::Collection.for_drop(Liquid::Drops::ApplicationPlan).new(@plans)
    assert_equal collection['my_plan'].class, Liquid::Drops::ApplicationPlan
  end

  test 'changes name with content' do
    c = Liquid::Drops::Collection.for_drop(Liquid::Drops::ApplicationPlan).new(@plans)
    assert_match /Collection *\(ApplicationPlan\)/, c.class.name
  end

  test 'delegates allowed_name?, deprecated_name?' do
    c = Liquid::Drops::Collection.for_drop(Liquid::Drops::ApplicationPlan).new(@plans)
    assert c.class.allowed_name?('plan')
    assert c.class.respond_to?(:deprecated_name?)
  end

  test 'can contain different types' do
    c = Liquid::Drops::Collection.new [ FactoryBot.create(:application_plan, system_name: 'my_app_plan'),
                                        FactoryBot.create(:account_plan, system_name: 'my_account_plan')
                                      ]
    assert_equal Liquid::Drops::ApplicationPlan, c.first.class
    assert_equal Liquid::Drops::AccountPlan, c.second.class
    assert_equal 'Collection', c.class.name
    assert c.class.allowed_name?('plans')
  end

  test 'empty array' do
    c = Liquid::Drops::Collection.for_drop(Liquid::Drops::Account).new([])
    assert_empty c
  end

end
