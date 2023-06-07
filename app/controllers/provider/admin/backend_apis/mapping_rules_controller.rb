# frozen_string_literal: true

class Provider::Admin::BackendApis::MappingRulesController < Provider::Admin::BackendApis::BaseController
  include ThreeScale::Search::Helpers
  include ProxyRuleSharedController

  activate_menu :backend_api, :mapping_rules

  delegate :proxy_rules, to: :@backend_api

  def create
    @proxy_rule = proxy_rules.build(proxy_rule_params)
    if @proxy_rule.save
      redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api), notice: 'Mapping rule was created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proxy_rule.update(proxy_rule_params)
      redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api), notice: 'Mapping rule was updated.'
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

    redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api)
  end

  private

  def owner_id
    @backend_api.id
  end
end
