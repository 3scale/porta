# frozen_string_literal: true

class Provider::Admin::CMS::SectionsController < Provider::Admin::CMS::BaseController
  before_action :available_sections, only: %i[edit new]
  before_action :find_section, only: %i[edit update destroy]
  before_action :find_children, only: %i[edit update]

  activate_menu :audience, :cms, :content

  def new
    @section = current_account.sections.build
  end

  def edit; end

  def create
    @section = current_account.sections.build(section_params)

    if @section.save
      redirect_to({ action: :edit, id: @section.id }, success: t('.success'))
    else
      render :action => :new
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    @section.valid? or raise t('.invalid')

    @section.add_remove_by_ids(:section, params[:cms_section][:cms_section_ids])
    @section.add_remove_by_ids(:page, params[:cms_section][:cms_page_ids])
    @section.add_remove_by_ids(:file, params[:cms_section][:cms_file_ids])
    @section.add_remove_by_ids(:builtin, params[:cms_section][:cms_builtin_ids])
    @section.save!

    if @section.update(section_params)
      redirect_to({ action: :edit, id: @section.id }, success: t('.success'))
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
        redirect_to edit_provider_admin_cms_section_path(@section), danger: t('.success')
      end
    else
      render_error status: :method_not_allowed, text: t('.not_allowed')
    end
  end

  protected

  def section_params
    params.require(:cms_section).permit(:parent_id, :title, :public, :partial_path)
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
