# frozen_string_literal: true

class DeveloperPortal::Admin::ApplicationsController < ::DeveloperPortal::BaseController
  self.responder = ThreeScale::Api::Responder

  include Liquid::TemplateSupport

  respond_to :html

  before_action :authorize_new_app, :only => [:new]
  before_action :authorize_create_app, :only => [:create]
  before_action :authorize_update_app,  :only => [:edit, :update]

  activate_menu :dashboard, :applications

  self.builtin_template_scope = 'applications'

  liquify prefix: 'applications'

  def index
    cinstances = current_account.bought_cinstances.includes(:service)
                   .order_for_dev_portal.paginate(page: params[:page])
    collection = Liquid::Drops::Collection.for_drop(Liquid::Drops::Application).new(cinstances)
    pagination = Liquid::Drops::Pagination.new(cinstances, self)

    assign_drops applications: collection, pagination: pagination
  end

  def new
    unless default_plan || first_published_plan
      return render_error "No published plan", :status => :not_found
    end

    if msg = current_account.cannot_create_application?(service)
      # Redirect to service selector if there is no service in scope
      # and provider has multiple active services
      flash[:error] = msg
      redirect_to admin_buyer_services_path
    end

    application = new_application
    application.plan ||= first_published_plan

    assign_drops application: application
  end

  def show
    assign_drops application: application
    assign_drops referrer_filter: application.referrer_filters.build
  end

  def edit
    assign_drops application: application
  end

  def update
    # HACK: If params only include `redirect_url` no validate extra fields
    # this mean that process the "oauth redirec_url"
    unless application_params.keys == ['redirect_url']
      application.validate_human_edition!
      application.validate_fields!
    end

    application.update_attributes(application_params)
    assign_drops application: application
    # make sure to prevent xss on js rendering if this notice is changed to include e.g. application name
    if application.valid?
      flash[:notice] = 'Application was successfully updated.'
      respond_with(application) do | f |
        f.js { render js: "jQuery.flash.notice('#{flash[:notice]}');" }
      end
    else
      respond_with(application) do | f |
        f.js { render js: %[jQuery.flash.error("#{application.errors.full_messages.to_sentence}");] }
      end
    end
  end

  def create
    application = new_application

    application.validate_human_edition!
    application.validate_fields!
    application.validate_contract_hierarchy!
    application.validate_plan_is_unique!
    if application.save
      flash[:notice] = 'Application was successfully created.'
    end

    assign_drops application: application
    respond_with(application)
  end

  def choose_service
    @services = current_account.services_can_create_app_on
    redirect_to new_admin_application_path(:service_id => @services.first.id) if @services.count == 1
    assign_drops services: Liquid::Drops::Collection.new(@services)
  end

  def destroy
    if application.destroy
      flash[:notice] = 'Application was successfully deleted.'
    else
      flash[:error] = 'Application could not be deleted.'
    end
    redirect_to action: :index
  end

  protected

  def applications
    current_account.bought_cinstances
  end

  def service
    @service ||= if not site_account.multiservice?
                   site_account.services.default
                 elsif service_id = params[:service_id]
                   site_account.services.find_by_id_or_system_name(service_id)
                 end
  end

  def application
    @cinstance ||= applications.find(params[:id])
  end

  def new_application
    @cinstance ||= applications.build_with_fields(application_params) do |application|
      application.plan = application.can_change_plan?(service) ? plan : default_plan
    end
  end

  def default_plan
    service.default_application_plan
  end

  def first_published_plan
    service.application_plans.published.first
  end

  def plan
    if plan_id = application_params[:plan_id]
      service.application_plans.find(plan_id)
    else
      default_plan
    end
  end

  def application_params
    @application_params ||= accepted_application_params
  end

  def authorize_new_app
    if service
      authorize! :create_application, service
    else
      redirect_to choose_service_admin_applications_path
    end
  end

  def authorize_create_app
    authorize! :create, new_application
  end

  def authorize_update_app
    authorize! :update, application
  end

  def accepted_application_params
    # cinstance[*] naming is present for legacy reasons
    application_attributes = params[:application] || params[:cinstance]
    return {} unless application_attributes
    permitted_params = fields_definitions + %i[plan_id redirect_url]
    application_attributes.permit(*permitted_params)
  end

  def fields_definitions
    FieldsDefinition.by_provider(site_account).by_target('Cinstance').pluck(:name)
  end
end
