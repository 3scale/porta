##= $:.unshift(File.expand_path(File.dirname(__FILE__)))
##= require 'app/lib/three_scale/api/sour'
##=
##= namespace 'CMS API'
##= resourcePath '/admin/api/cms/sections'
##= swaggerVersion "1.1"
##= apiVersion "1.0"
##=
##= module Threescale::Api::Sour::Operation
##=    def section_model_params
##=      param_system_name
##=      param 'title', 'Title of the section'
##=      param 'public', 'Public or not', default: 'true', type: 'boolean'
##=      param 'parent_id', 'ID of a parent section', default: 'root section id', type: 'int'
##=      param 'partial_path', 'Path of the section'
##=    end
##=  end
##=
##=
##= Sour::Operation.mixin(Threescale::Api::Sour::Operation)
##=
##=

class Admin::Api::CMS::SectionsController < Admin::Api::CMS::BaseController

  wrap_parameters :section, include: [:title, :public, :parent_id, :partial_path]

  before_action :find_section, only: [:show, :update, :destroy]

  representer :entity => ::CMS::SectionRepresenter, :collection => ::CMS::SectionsRepresenter

  ##=  api("/admin/api/cms/sections.xml", 'List[short-section') {
  ##=    GET('List all sections') {
  ##=      paginated
  ##=      requires_access_token
  ##=    }
  def index
    @sections = current_account.sections.page(params[:page] || 1).per_page(per_page)
    respond_with @sections
  end

  ##=    POST('Create section') {
  ##=      requires_access_token
  ##=      section_model_params
  ##=    }
  ##=  }
  def create
    create_params = params.require(:section).permit!
    parent_id = create_params.delete(:parent_id)
    @section = current_account.sections.build(create_params)

    if current_account.sections.exists?(id: parent_id)
      @section.parent_id = parent_id
    else
      @section.parent = current_account.sections.root
    end
    @section.save
    respond_with @section, location: admin_api_cms_sections_path(@section)
  end

  ##=   api("/admin/api/cms/sections/{id}.xml", 'template') {
  ##=     GET('View section') {
  ##=       requires_access_token
  ##=       id 'ID of the section'
  ##=     }
  def show
    respond_with @section
  end

  ##=     PUT('Update section') {
  ##=       requires_access_token
  ##=       id 'ID of the section'
  ##=       section_model_params
  ##=     }
  def update
    @section.update_attributes(params[:section])
    respond_with @section
  end

  ##=     DELETE('Destroy section') {
  ##=       requires_access_token
  ##=       id 'ID of the section'
  ##=     }
  ##=   }
  def destroy
    if @section.respond_to?(:destroy)
      @section.destroy
      respond_with @section, location: admin_api_cms_sections_path(@section)
    else
      render_error status: :method_not_allowed, text: "This section can't be deleted"
    end
  end

  private
    def find_section
      @section = current_account.sections.find_by_id(params[:id]) || current_account.sections.find_by_system_name(params[:id])

      raise ActiveRecord::RecordNotFound.new("Couldn't find CMS::Section with id or system_name=#{params[:id]}") if @section.nil?
    end
end
