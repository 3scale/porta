class Provider::Admin::CMS::SectionsController < Provider::Admin::CMS::BaseController

  activate_menu :audience, :cms, :content
  before_action :available_sections, :only => [:edit, :new ]
  before_action :find_section , :only => [:show, :edit, :update, :destroy ]
  before_action :find_children , :only => [:show, :edit, :update]

  def index
    @sections = current_account.sections
  end

  def show
  end

  def new
    @section = current_account.sections.build
  end

  def edit
  end

  def create
    @section = current_account.sections.build(section_params)

    if @section.save
      flash[:info] = 'Section created successfully.'
      redirect_to :action => :edit, :id => @section.id
    else
      render :action => :new
    end
  end

  def update
    @section.valid? or raise "Invalid section"

    @section.add_remove_by_ids( :section, params[:cms_section][:cms_section_ids])
    @section.add_remove_by_ids( :page, params[:cms_section][:cms_page_ids])
    @section.add_remove_by_ids( :file, params[:cms_section][:cms_file_ids])
    @section.add_remove_by_ids( :builtin, params[:cms_section][:cms_builtin_ids])
    @section.save!

    if @section.update_attributes(section_params)
      flash[:info] = 'section saved successfully.'
      redirect_to( :action => :edit, :id => @section.id)
    else
      render :action => :edit
    end
  end

  def destroy
    parent = @section.parent
    if @section.respond_to?(:destroy)
      if @section.destroy
        redirect_to edit_provider_admin_cms_section_path(parent)
      else
        flash[:error] = 'Failed to delete the section.'
        redirect_to edit_provider_admin_cms_section_path(@section)
      end
    else
      render_error status: :method_not_allowed, text: "This section can't be deleted"
    end
  end

  protected

  def section_params
    params[:cms_section].dup.tap do |params|
      params[:parent] = if id = params[:parent_id]
                          current_account.sections.find(id)
                        end
    end
  end


  def available_sections
    @available_sections = current_account.sections
  end

  def find_section
    @section = current_account.sections.find(params[:id])
  end

  def find_children
    @attached_pages = @section.pages
    @attached_files = @section.files
    @attached_builtins = @section.builtins
    @attached_sections = @section.children
  end

end
