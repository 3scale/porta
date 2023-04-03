class Admin::Api::CMS::SectionsController < Admin::Api::CMS::BaseController
  ##~ sapi = source2swagger.namespace("CMS API")
  ##~ @parameter_section_id = { :name => "id", :description => "ID of the section", :dataType => "int", :required => true, :paramType => "path" }

  ALLOWED_PARAMS = %i[parent_id title system_name public partial_path].freeze
  wrap_parameters :section, include: ALLOWED_PARAMS

  before_action :find_section, only: %i[show update destroy]

  representer :entity => ::CMS::SectionRepresenter, :collection => ::CMS::SectionsRepresenter

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/sections.json"
  ##~ e.responseClass = "List[short-section]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Section List"
  ##~ op.description = "List all sections"
  ##~ op.group = "cms_sections"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  def index
    @sections = current_account.sections.page(params[:page] || 1).per_page(per_page)
    respond_with @sections
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Section Create"
  ##~ op.description = "Create section"
  ##~ op.group = "cms_sections"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "title", :description => "Title of the section", :paramType => "query", :required => true
  ##~ op.parameters.add :name => "system_name", :description => "Human readable and unique identifier", :paramType => "query"
  ##~ op.parameters.add :name => "public", :description => "Public or not", :default => "true", :type => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "parent_id", :description => "ID of a parent section", :paramType => "query", :default => "root section id", :type => "int"
  ##~ op.parameters.add :name => "partial_path", :description => "Path of the section", :paramType => "query"
  def create
    @section = current_account.sections.build(section_params)
    @section.parent = current_account.sections.find_by(id: params[:parent_id]) || current_account.sections.root
    @section.save

    respond_with @section, location: admin_api_cms_sections_path(@section)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/sections/{id}.json"
  ##~ e.responseClass = "template"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Section Read"
  ##~ op.description = "View section"
  ##~ op.group       = "cms_sections"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_section_id
  def show
    respond_with @section
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "Section Update"
  ##~ op.description = "Update section"
  ##~ op.group       = "cms_sections"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_section_id
  ##~ op.parameters.add :name => "title", :description => "Title of the section", :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "Human readable and unique identifier", :paramType => "query"
  ##~ op.parameters.add :name => "public", :description => "Public or not", :default => "true", :type => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "parent_id", :description => "ID of a parent section", :paramType => "query", :default => "root section id", :type => "int"
  ##~ op.parameters.add :name => "partial_path", :description => "Path of the section", :paramType => "query"
  def update
    @section.update_attributes(section_params)
    respond_with @section
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "DELETE"
  ##~ op.summary     = "Section Delete"
  ##~ op.description = "Delete section"
  ##~ op.group       = "cms_sections"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_section_id
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
