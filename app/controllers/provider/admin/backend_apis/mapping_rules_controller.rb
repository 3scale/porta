# frozen_string_literal: true

class Provider::Admin::BackendApis::MappingRulesController < Provider::Admin::BackendApis::BaseController
  include ThreeScale::Search::Helpers
  include ProxyRuleSharedController

  activate_menu :backend_api, :mapping_rules

  delegate :proxy_rules, to: :@backend_api

  def index
    @presenter = Provider::Admin::BackendApis::MappingRulesIndexPresenter.new(backend_api: @backend_api, params: params)
  end

  def create
    @proxy_rule = proxy_rules.build(proxy_rule_params)
    if @proxy_rule.save
      redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api), success: t('.success')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proxy_rule.update(proxy_rule_params)
      redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api), success: t('.success')
    else
      render :edit
    end
  end

  def destroy
    if @proxy_rule.destroy
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.error')
    end

    redirect_to provider_admin_backend_api_mapping_rules_path(@backend_api)
  end
end
