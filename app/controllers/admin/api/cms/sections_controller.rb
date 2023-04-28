class Admin::Api::CMS::SectionsController < Admin::Api::CMS::BaseController

  ALLOWED_PARAMS = %i[parent_id title system_name public partial_path].freeze
  wrap_parameters :section, include: ALLOWED_PARAMS

  before_action :find_section, only: %i[show update destroy]

  representer :entity => ::CMS::SectionRepresenter, :collection => ::CMS::SectionsRepresenter

  # Section List
  # GET /admin/api/cms/sections.json
  def index
    @sections = current_account.sections.scope_search(search).paginate(pagination_params)
    respond_with @sections
  end

  # Section Create
  # POST /admin/api/cms/sections.json
  def create
    @section = current_account.sections.build(section_params)
    @section.parent = current_account.sections.find_by(id: params[:parent_id]) || current_account.sections.root
    @section.save

    respond_with @section, location: admin_api_cms_sections_path(@section)
  end

  # Section Read
  # GET /admin/api/cms/sections/{id}.json
  def show
    respond_with @section
  end

  # Section Update
  # PUT /admin/api/cms/sections/{id}.json
  def update
    @section.update_attributes(section_params)
    respond_with @section
  end

  # Section Delete
  # DELETE /admin/api/cms/sections/{id}.json
  def destroy
    if @section.respond_to?(:destroy)
      @section.destroy
      respond_with @section, location: admin_api_cms_sections_path(@section)
    else
      render_error status: :method_not_allowed, text: "This section can't be deleted"
    end
  end

  private

  def section_params
    params.require(:section).permit(ALLOWED_PARAMS)
  end

  def find_section
    @section = current_account.sections.where(id: params[:id]).or(current_account.sections.where(system_name: params[:id])).first

    raise ActiveRecord::RecordNotFound, "Couldn't find CMS::Section with id or system_name=#{params[:id]}" if @section.blank?
  end
end
