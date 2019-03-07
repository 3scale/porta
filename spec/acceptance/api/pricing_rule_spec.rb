require 'rails_helper'

resource "PricingRule" do

  let(:service) { provider.services.default }
  let(:metric) { service.metrics.hits }
  let(:plan) { FactoryBot.create(:application_plan, issuer: service) }

  let(:resource) { FactoryBot.build(:pricing_rule, plan: plan, metric: metric, min: 2, max: 5) }

  api 'pricing rule' do

    let(:plan_id) { plan.id }

    get "/admin/api/application_plans/:plan_id/pricing_rules.:format", action: :index do
    end

    get "/admin/api/application_plans/:plan_id/metrics/:metric_id/pricing_rules.:format", action: :index do
      let(:metric_id) { metric.id }
    end

    context do
      parameter :min, 'min'
      parameter :max, 'max'
      parameter :cost_per_unit, 'cost per unit'

      let(:metric_id) { metric.id }
      let(:cost_per_unit) { 5.55 }
      let(:min) { 1 }
      let(:max) { 2 }

      post '/admin/api/application_plans/:plan_id/metrics/:metric_id/pricing_rules.:format', action: :create
    end
  end

  json(:resource) do
    let(:root) { 'pricing_rule' }
    it { should have_properties(%w|id metric_id cost_per_unit min max|).from(resource) }
    it { should have_links('metric', 'plan') }
  end

  json(:collection) do
    let(:root) { 'pricing_rules' }
    it { should be_an(Array) }
  end
end

__END__
         admin_api_application_plan_pricing_rules GET      /admin/api/application_plans/:application_plan_id/pricing_rules(.:format)                        admin/api/application_plan_pricing_rules#index {:format=>"xml"}
  admin_api_application_plan_metric_pricing_rules GET      /admin/api/application_plans/:application_plan_id/metrics/:metric_id/pricing_rules(.:format)     admin/api/application_plan_metric_pricing_rules#index {:format=>"xml"}
  admin_api_application_plan_metric_pricing_rules POST     /admin/api/application_plans/:application_plan_id/metrics/:metric_id/pricing_rules(.:format)     admin/api/application_plan_metric_pricing_rules#create {:format=>"xml"}
