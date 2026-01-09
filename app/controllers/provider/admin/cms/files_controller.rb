# frozen_string_literal: true

class Provider::Admin::CMS::FilesController < Provider::Admin::CMS::BaseController
  activate_menu :audience, :cms, :content

  def new
    @file = files.new
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
      redirect_to edit_provider_admin_cms_file_path(@file), success: t('.success')
    else
      render :new
    end
  end

  def update
    @file = file
    if @file.update(file_params)
      redirect_to edit_provider_admin_cms_file_path(@file)
    else
      render :edit
    end
  end

  def destroy
    file.destroy

    redirect_to provider_admin_cms_templates_path, success: t('.success', path: file.path)
  end

  private

  def file_params
    params.require(:cms_file).permit(:path, :attachment, :downloadable, :tag_list, :section_id)
  end

  def files
    @files ||= current_account.files
  end

  def file
    @file ||= files.find(params[:id])
  end
end
