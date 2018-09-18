# -*- coding: utf-8 -*-
class Api::PlansBaseController < Api::BaseController
  include ThreeScale::Search::Helpers

  before_action :deny_on_premises_for_master
  before_action :authorize_plans

  before_action :find_plan, :only => [:show, :edit, :update, :destroy, :copy, :masterize]
  before_action :find_plans, :only => [:index]

  before_action :check_plan_can_be_deleted, :only => [:destroy]

  activate_menu :serviceadmin

  class UndefinedCollectionMethod < StandardError; end

  # TODO: sublayout 'api/services' when AccountPlans and OtherPlans
  # have different controllers
  protected

  def authorize_plans
    authorize! :admin, :plans
  end

  def authorize_manage_plans
    authorize! :manage, :plans
  end

  def resource(id = params[:id])
    collection.readonly(false).find_by_id(id)
  end

  def collection
    raise UndefinedCollectionMethod.new('You have to override collection method')
  end

  def find_plan
    @plan = resource
  end

  def find_plans
    @plans = collection.order_by(params[:sort], params[:direction])
  end

  def find_issuer
    @issuer = resource.issuer
  end

  private

  def create(attrs)
    @plan = collection.build(attrs)
    @plan.system_name = attrs[:system_name]

    if @plan.save
      if block_given?
        yield
      else
        @plan.reload

        respond_to do |format|
          format.html do
            flash[:notice] = "Created #{@plan.class.model_name.human} #{@plan.name}"
            # collection.build to create new record to properly generate path to index action (rails)
            redirect_to plans_index_path
          end
        end
      end

    else
      render :new
    end
  end # def create

  def update(attrs)
    if @plan.update_attributes(attrs)

      if block_given?
        yield
      else
        redirect_to plans_index_path
      end

    else
      render :edit
    end
  end # end update

  def destroy
    @plan.destroy

    if block_given?
      yield
    else
      flash[:notice] = 'The plan was deleted'
      redirect_to plans_index_path
    end
  end

  def plans_index_path
    polymorphic_path([:admin, @plan.issuer, collection.build])
  end

  protected

  def generic_masterize_plan(issuer, assoc)
    masterize_plan do
      if @plan.nil? || issuer.send(assoc) == @plan
        issuer.send("#{assoc}=", nil)
      else
        issuer.send("#{assoc}=", @plan)
      end

      issuer.save!
    end
  end

  # this is supposed to be called via ajax and we need only to flash stuff
  def masterize_plan
    yield

    render :js => '$.flash.notice("Default plan was updated");'
  end

  # REFACTOR: this has nothing to do in a controller layer!
  def check_plan_can_be_deleted
    unless @plan.can_be_destroyed?
      flash[:error] = @plan.errors.full_messages.to_sentence

      return redirect_to(plans_index_path)
    end
  end
end
