# frozen_string_literal: true

class Api::ProxyRulesController < Api::BaseController
  include ThreeScale::Search::Helpers
  include ProxyRuleSharedController

  delegate :proxy_rules, to: :proxy

  activate_menu :serviceadmin, :integration, :mapping_rules

  sublayout 'api/service'

  def create
    @proxy_rule = proxy_rules.build(proxy_rule_params)
    if @proxy_rule.save
      redirect_to admin_service_proxy_rules_path(@service), notice: 'Mapping rule was created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proxy_rule.update_attributes(proxy_rule_params)
      redirect_to admin_service_proxy_rules_path(@service), notice: 'Mapping rule was updated.'
    else
      render :edit
    end
  end

  def destroy
    if @proxy_rule.destroy
      flash[:notice] = 'The mapping rule was deleted'
    else
      flash[:error] = 'The mapping rule cannot be deleted'
    end

    redirect_to admin_service_proxy_rules_path(@service)
  end

  private

  def proxy
    @proxy ||= service.proxy
  end

  def service
    @service ||= current_user.accessible_services.find(params[:service_id])
  end

  def owner_id
    proxy.id
  end
end
