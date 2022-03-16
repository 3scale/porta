# frozen_string_literal: true

class Provider::Admin::Account::UsersController < Provider::Admin::Account::BaseController
  inherit_resources
  defaults :route_prefix => 'provider_admin_account'
  actions :index, :edit, :update, :destroy

  before_action :load_services, only: %i[edit update]

  authorize_resource

  activate_menu :account, :users, :listing

  def update
    resource.validate_fields!

    update! do |success, failure|
      success.html do
        flash[:notice] = 'User was successfully updated.'
        redirect_to(collection_url)
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

  def collection
    @users ||= end_of_association_chain.but_impersonation_admin.paginate(page: params[:page]).decorate
  end

  def update_resource(user, attributes)
    # FIXME: in rails 3, we're getting an array
    attributes = attributes.first

    # And in rails 5, it can be ActionController::Parameters or hash
    attributes = ActionController::Parameters.new(attributes) unless attributes.is_a?(ActionController::Parameters)
    protected_attributes = attributes.permit(User::Permissions::ATTRIBUTES)

    protected_attributes.extract!(:member_permission_service_ids) unless current_account.provider_can_use?(:service_permissions)

    user.class.transaction do
      user.assign_attributes(attributes)
      user.assign_attributes(protected_attributes, without_protection: can?(:update_role, user))

      user.save
    end
  end
end
