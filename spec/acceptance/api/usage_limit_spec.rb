require 'spec_helper'

resource "UsageLimit" do

  let(:service) { provider.services.default }
  let(:metric)  { service.metrics.hits }

  let(:plan_id) { plan.id }
  let(:metric_id) { metric.id }

  let(:resource) { FactoryBot.build(:usage_limit, metric: metric, plan: plan) }

  api 'application plan limits' do
    let(:plan) { FactoryBot.create(:application_plan, issuer: service) }

    get '/admin/api/application_plans/:plan_id/limits.:format', action: :index
    get '/admin/api/application_plans/:plan_id/metrics/:metric_id/limits.:format', action: :index

    get  '/admin/api/application_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :show
    delete  '/admin/api/application_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :destroy

    context do
      parameter :period, 'Limit Period'

      post '/admin/api/application_plans/:plan_id/metrics/:metric_id/limits.:format', action: :create do
        let(:period) { 'week' }
      end

      put  '/admin/api/application_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :update do
        let(:period) { 'eternity' }
      end
    end
  end

  api 'end user plan limits' do
    before { provider.settings.allow_end_users! }

    let(:plan) { FactoryBot.create(:end_user_plan, issuer: service) }

    get '/admin/api/end_user_plans/:plan_id/metrics/:metric_id/limits.:format', action: :index
    get  '/admin/api/end_user_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :show
    delete  '/admin/api/end_user_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :destroy

    context do
      parameter :period, 'Limit Period'

      post '/admin/api/end_user_plans/:plan_id/metrics/:metric_id/limits.:format', action: :create do
        let(:period) { 'week' }
      end

      put  '/admin/api/end_user_plans/:plan_id/metrics/:metric_id/limits/:id.:format', action: :update do
        let(:period) { 'eternity' }
      end
    end
  end

  context do
    let(:plan) { FactoryBot.build(:application_plan, issuer: service) }

    json(:resource) do
      let(:root) { 'limit' }
      it { should have_properties('id', 'value', 'period', 'metric_id').from(resource) }
      it { should have_links('self', 'metric', 'plan') }
    end

    json(:collection) do
      let(:root) { 'limits' }
      it { should be_an(Array) }
    end
  end
end

__END__
                    admin_api_application_plan_limits GET    /admin/api/application_plans/:application_plan_id/limits(.:format)                                     admin/api/application_plan_limits#index {:format=>"xml"}
             admin_api_application_plan_metric_limits GET    /admin/api/application_plans/:application_plan_id/metrics/:metric_id/limits(.:format)                  admin/api/application_plan_metric_limits#index {:format=>"xml"}
                                                      POST   /admin/api/application_plans/:application_plan_id/metrics/:metric_id/limits(.:format)                  admin/api/application_plan_metric_limits#create {:format=>"xml"}
              admin_api_application_plan_metric_limit GET    /admin/api/application_plans/:application_plan_id/metrics/:metric_id/limits/:id(.:format)              admin/api/application_plan_metric_limits#show {:format=>"xml"}
                                                      PUT    /admin/api/application_plans/:application_plan_id/metrics/:metric_id/limits/:id(.:format)              admin/api/application_plan_metric_limits#update {:format=>"xml"}
                                                      DELETE /admin/api/application_plans/:application_plan_id/metrics/:metric_id/limits/:id(.:format)              admin/api/application_plan_metric_limits#destroy {:format=>"xml"}


                admin_api_end_user_plan_metric_limits GET    /admin/api/end_user_plans/:end_user_plan_id/metrics/:metric_id/limits(.:format)                        admin/api/end_user_plans/limits#index {:format=>"xml"}
                                                      POST   /admin/api/end_user_plans/:end_user_plan_id/metrics/:metric_id/limits(.:format)                        admin/api/end_user_plans/limits#create {:format=>"xml"}
                 admin_api_end_user_plan_metric_limit GET    /admin/api/end_user_plans/:end_user_plan_id/metrics/:metric_id/limits/:id(.:format)                    admin/api/end_user_plans/limits#show {:format=>"xml"}
                                                      PUT    /admin/api/end_user_plans/:end_user_plan_id/metrics/:metric_id/limits/:id(.:format)                    admin/api/end_user_plans/limits#update {:format=>"xml"}
                                                      DELETE /admin/api/end_user_plans/:end_user_plan_id/metrics/:metric_id/limits/:id(.:format)                    admin/api/end_user_plans/limits#destroy {:format=>"xml"}
