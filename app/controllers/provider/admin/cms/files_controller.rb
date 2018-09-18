class Provider::Admin::CMS::FilesController < Provider::Admin::CMS::BaseController

  activate_menu :cms, :content

  def index
    @files = files
  end

  def new
    @file = current_account.files.new
  end

  def edit
    @file = file

    respond_to do |format|
      format.html
      format.js { render :template => '/provider/admin/cms/templates/edit' }
    end
  end

  def create
    @file = files.new(file_params)
    if @file.save
      redirect_to edit_provider_admin_cms_file_path(@file), notice: 'Created new file'
    else
      render :new
    end
  end

  def update
    @file = file
    if @file.update_attributes(file_params)
      redirect_to edit_provider_admin_cms_file_path(@file)
    else
      render :edit
    end
  end

  def destroy
    file.destroy

    flash[:success] = "File #{file.path} deleted"

    redirect_to provider_admin_cms_templates_path
  end

  private

  def file_params
    params[:cms_file].dup.tap do |params|
      if section = params[:section_id]
        params[:section] = current_account.sections.find(section)
      end
    end
  end

  def files
    @_files ||= current_account.files
  end

  def file
    @_file ||= files.find(params[:id])
  end

end
