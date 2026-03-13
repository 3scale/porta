# frozen_string_literal: true

class Provider::Admin::Account::UsersController < Provider::Admin::Account::BaseController
  inherit_resources
  defaults :route_prefix => 'provider_admin_account'
  actions :edit, :update, :destroy

  before_action :load_services, only: %i[edit update]

  authorize_resource

  activate_menu :account, :users, :listing

  helper_method :presenter

  attr_reader :presenter

  def index
    users = end_of_association_chain.but_impersonation_admin
    @presenter = Provider::Admin::Account::UsersIndexPresenter.new(current_user: current_user,
                                                                   users: users,
                                                                   params: params)
  end

  def destroy
    destroy! do |success|
      success.html do
        flash[:success] = t('.success')
        super
      end
    end
  end

  def update
    resource.validate_fields!

    update! do |success, failure|
      success.html do
        redirect_to collection_url, success: t('.success')
      end
    end
  end

  private

  def load_services
    @services ||= current_account.accessible_services
  end

  def begin_of_association_chain
    current_account
  end

  def update_resource(user, attributes)
    allowed_attrs = user.defined_builtin_fields_names + %w[password password_confirmation]

    if can?(:update_role, user)
      allowed_attrs += [:role, member_permission_ids: []]
      allowed_attrs += [:member_permission_service_ids, member_permission_service_ids: []] if current_account.provider_can_use?(:service_permissions)
    end

    permitted_attributes = attributes.permit(*allowed_attrs, extra_fields: user.defined_extra_fields_names)

    user.update(permitted_attributes)
  end

  def resource_params
    params.fetch(:user, {})
  end
end
