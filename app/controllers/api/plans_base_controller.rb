# frozen_string_literal: true

# This class smells of :reek:TooManyMethods but we don't care.
class Api::PlansBaseController < Api::BaseController
  include ThreeScale::Search::Helpers

  before_action :deny_on_premises_for_master
  before_action :authorize_section
  before_action :authorize_action, only: %i[new create destroy]
  before_action :find_plan, except: %i[index new create]
  before_action :find_service
  before_action :check_plan_can_be_deleted, only: :destroy

  activate_menu :serviceadmin

  delegate :plans, to: :presenter

  class UndefinedCollectionMethod < StandardError; end
  class UndefinedPlanTypeMethod < StandardError; end

  def index; end

  def new
    @plan = collection.build params[plan_type]
  end

  protected

  def authorize_section
    authorize! :manage, :plans
  end

  def authorize_action
    authorize! :create, :plans
  end

  def resource(id = params[:id])
    return if id.blank?

    collection.readonly(false).find(id)
  end

  def collection
    raise UndefinedCollectionMethod, 'You have to override collection method'
  end

  def plan_type
    raise UndefinedPlanTypeMethod, 'You have to override plan_type method'
  end

  def find_plan
    @plan = resource
  end

  def find_service
    service_id = params[:service_id].presence || (plan.issuer_id if plan&.issuer_type == 'Service')
    return unless service_id

    @service = current_user.accessible_services.find(service_id)
    authorize! :show, service
  end

  private

  attr_reader :plan, :service

  CREATE_PARAMS = %i[name system_name approval_required trial_period_days setup_fee cost_per_month].freeze
  UPDATE_PARAMS = (CREATE_PARAMS - [:system_name]).freeze

  # FIXME: this method smells of :reek:TooManyStatements
  def create # rubocop:disable Metrics/AbcSize
    attrs = params.require(plan_type).permit(CREATE_PARAMS)
    @plan = collection.build(attrs)

    if plan.save
      if block_given?
        yield
      else
        plan.reload

        # collection.build to create new record to properly generate path to index action (rails)
        redirect_to plans_index_path, success: t('api.plans.create.success', type: plan.class.model_name.human, name: plan.name)
      end

    else
      render :new
    end
  end

  def update
    attrs = params.require(plan_type).permit(UPDATE_PARAMS)
    if plan.update(attrs)

      if block_given?
        yield
      else
        redirect_to plans_index_path
      end

    else
      render :edit
    end
  end

  def destroy
    plan.destroy

    return yield if block_given?

    json = { success: t('.success'), id: plan.id }
    respond_to do |format|
      format.json { render json: json, status: :ok }
    end
  end

  def plans_index_path
    polymorphic_path([:admin, service, collection.build])
  end

  def assign_plan!(issuer, assoc)
    assigned_plan = !plan || issuer.send(assoc) == plan ? nil : plan
    issuer.send("#{assoc}=", assigned_plan)
    issuer.save!
  end

  def masterize(issuer, assoc)
    assign_plan!(issuer, assoc)
    redirect_to plans_index_path, success: t('api.plans.masterize.success')
  end

  # REFACTOR: this has nothing to do in a controller layer!
  def check_plan_can_be_deleted
    return if plan.can_be_destroyed?

    redirect_to plans_index_path, danger: plan.errors.full_messages.to_sentence
  end
end
