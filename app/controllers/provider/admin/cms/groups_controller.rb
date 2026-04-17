# frozen_string_literal: true

class Provider::Admin::CMS::GroupsController < Provider::Admin::CMS::BaseController
  before_action :available_groups, :only => %i[edit new]
  before_action :available_sections, :only => %i[edit new]
  before_action :authorize_groups
  before_action :validate_section_ids, only: %i[create update]

  activate_menu :audience, :cms, :groups

  sublayout nil

  def index
    @groups = current_account.provided_groups
  end

  def show
    @group = current_account.provided_groups.find(params[:id])
  end

  def new
    @group = current_account.provided_groups.new
  end

  def edit
    @group = current_account.provided_groups.find(params[:id])
  end

  def create
    @group = current_account.provided_groups.build(group_params)

    if @group.save
      redirect_to({ action: :index }, success: t('.success'))
    else
      available_groups
      available_sections
      render :action => :new
    end
  end

  def update
    @group = current_account.provided_groups.find(params[:id])

    if @group.update(group_params)
      redirect_to({ action: :index }, success: t('.success'))
    else
      available_groups
      available_sections
      render :action => :index
    end
  end

  def destroy
    @group = current_account.provided_groups.find(params[:id])
    @group.destroy
    redirect_to({ action: :index }, success: t('.success'))
  end

  protected

  def group_params
    @group_params ||= params.require(:cms_group).permit(:name, section_ids: [])
  end

  def available_groups
    @available_groups = current_account.provided_groups
  end

  def available_sections
    @available_sections = current_account.provided_sections
  end

  def authorize_groups
    authorize! :manage, :groups
  end

  # Ensure that all section IDs provided in the parameters belong to the account, which is the group owner
  # Providing a non-existent section ID, or the one that belongs to another provider results in a Not Found error
  def validate_section_ids
    section_ids = group_params[:section_ids]
    return if section_ids.blank?

    section_ids.reject!(&:empty?)
    exising_section_ids = current_account.section_ids.map(&:to_s)

    render_error(:not_found, status: :not_found) if (section_ids.map(&:to_s) - exising_section_ids).any?
  end
end
