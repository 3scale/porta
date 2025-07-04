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
    # FIXME: in rails 3, we're getting an array
    attributes = attributes.first

    # After the rails 5.1 upgrade, attributes comes as ActionController::Parameters except when they are empty
    attributes = attributes.permit!.to_h unless attributes.is_a?(Hash)

    protected_attributes = attributes.extract!(*User::Permissions::ATTRIBUTES)

    unless current_account.provider_can_use?(:service_permissions)
      protected_attributes.except!(:member_permission_service_ids)
    end

    user.class.transaction do
      user.assign_attributes(attributes)
      user.assign_attributes(protected_attributes, without_protection: can?(:update_role, user))

      user.save
    end
  end
end
