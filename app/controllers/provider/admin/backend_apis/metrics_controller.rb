# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  before_action :find_metric, except: %i[new create index]
  before_action :build_metric, only: %i[new create]

  activate_menu :backend_api, :methods_metrics
  sublayout 'api/service'

  def index
    @metrics = @backend_api.metrics.top_level.includes(:proxy_rules)
    @service = @backend_api.first_service # FIXME: This is needed because the page is still using a helper shared with the old metrics page (app/helpers/services_helper.rb:26)
  end

  def new
    @service = @backend_api.first_service # FIXME: This is needed because the page is still pointing the form to the old metrics controller
    render template: '/api/metrics/new'
  end

  def edit
    @service = @backend_api.first_service # FIXME: This is needed because the page is still pointing the form to the old metrics controller
    render template: '/api/metrics/edit'
  end

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end

  private

  def find_metric
    @metric = @backend_api.metrics.find(params[:id])
  end

  def build_metric
    @metric = if params[:metric_id]
                @backend_api.metrics.find(params[:metric_id]).children
              else
                @backend_api.metrics
              end.build(params[:metric] || {})
  end
end
