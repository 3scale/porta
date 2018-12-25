require 'test_helper'

class Liquid::Filters::ParamFilterTest < ActiveSupport::TestCase
  include Liquid

  test 'plan drop converts to parameter' do
    plan = FactoryBot.create(:account_plan)
    txt = Liquid::Template.parse('{{ plan | to_param }}').render('plan' => wrap(plan))

    assert_equal "plan_ids[]=#{plan.id}", txt
  end

  test 'service drop converts to parameter' do
    service = FactoryBot.create(:service)
    txt = Liquid::Template.parse('{{ service | to_param }}').render('service' => wrap(service))

    assert_equal "service_id=#{service.id}", txt
  end

  test 'converts array to param string' do
    plans = (1..2).map { wrap(FactoryBot.create(:account_plan)) }
    txt = Liquid::Template.parse('{{ plans | to_param }}').render('plans' => plans)

    assert_equal "plan_ids[]=#{plans[0].id}&plan_ids[]=#{plans[1].id}", txt
  end

  private

  def wrap(model)
    "Liquid::Drops::#{model.class}".constantize.new(model)
  end

end
