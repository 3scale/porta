class Provider::Admin::CMS::GroupsController < Provider::Admin::CMS::BaseController
  before_action :available_groups, :only => [:edit, :new ]
  before_action :available_sections, :only => [:edit, :new ]
  before_action :authorize_groups

  activate_menu :cms, :groups

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
    @group = current_account.provided_groups.build(params[:cms_group])

    if @group.save
      flash[:info] = 'Group created.'
      redirect_to(:action => :index)
    else
      available_groups
      available_sections
      render :action => :new
    end
  end

  def update
    @group = current_account.provided_groups.find(params[:id])

    if @group.update_attributes(sections_params)
      flash[:info] = 'Group saved.'
      redirect_to( :action => :index)
    else
      available_groups
      available_sections
      render :action => :index
    end
  end

  def destroy
    @group = current_account.provided_groups.find(params[:id])
    @group.destroy
    flash[:notice] = 'Group deleted.'
    redirect_to :action => :index
  end



  protected

  def sections_params
    params[:cms_group].dup.tap do |params|
      if section_ids = params[:section_ids].presence
        section_ids.reject!(&:empty?)
        params[:sections] = section_ids.map do  |sec_id|
          current_account.sections.find(sec_id.to_i)
        end
      end
    end

  end

  def available_groups
    @available_groups= current_account.provided_groups
  end

  def available_sections
    @available_sections= current_account.provided_sections
  end

  def authorize_groups
    authorize! :manage, :groups
  end

end
