# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  before_action :find_metric, except: %i[new create index]
  before_action :build_metric, only: %i[new create]

  # FIXME: This should be removed. It is still needed because either
  #        1. the page is still pointing the form to the old metrics controller (new/edit) or
  #        2. the page uses a helper shared with the old metrics page (app/helpers/services_helper.rb:26) (index)
  before_action :find_service

  activate_menu :backend_api, :methods_metrics
  sublayout 'api/service'

  def index
    @metrics = @backend_api.top_level_metrics.includes(:proxy_rules)
  end

  def new
    render template: '/api/metrics/new'
  end

  def create
    # TODO: https://issues.jboss.org/browse/THREESCALE-3089
  end

  def edit
    render template: '/api/metrics/edit'
  end

  def update
    # TODO: https://issues.jboss.org/browse/THREESCALE-3089
  end

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end

  private

  def find_service
    @service = @backend_api.first_service
  end

  def find_metric
    @metric = find_backend_api_metric_by(params[:id])
  end

  def build_metric
    metrics = if (metric_id = params[:metric_id])
                find_backend_api_metric_by(metric_id).children
              else
                @backend_api.metrics
              end
    @metric = metrics.build(params[:metric] || {})
  end

  def find_backend_api_metric_by(id)
    @backend_api.metrics.find(id)
  end
end
