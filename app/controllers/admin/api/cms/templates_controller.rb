##= $:.unshift(File.expand_path(File.dirname(__FILE__)))
##= require 'app/lib/three_scale/api/sour'
##=
##= namespace 'CMS API'
##= resourcePath '/admin/api/cms/templates'
##= swaggerVersion "1.1"
##= apiVersion "1.0"
##=
##= module Threescale::Api::Sour::Operation
##=    def template_model_params
##=      param_system_name
##=      param 'title', 'Title of the template'
##=      param 'path', 'URI of the page'
##=      param 'draft', 'Text content of the template (you have to publish the template)'
##=      param 'section_name', 'system name of a section', type: 'string'
##=      param 'section_id', 'ID of a section (valid only for pages)', default: 'root section id', type: 'int'
##=      param 'layout_name', 'system name of a layout (valid only for pages)', type: 'string'
##=      param 'layout_id', 'ID of a layout - overrides layout_name', type: 'int'
##=      param 'liquid_enabled', 'liquid processing of the template content on/off', type: 'boolean'
##=      param 'handler', "text will be processed by the handler before rendering", choices: [ 'textile', 'markdown']
##=    end
##=  end
##=
##=
##= Sour::Operation.mixin(Threescale::Api::Sour::Operation)
##=
##=
class Admin::Api::CMS::TemplatesController < Admin::Api::CMS::BaseController

  ALLOWED_PARAMS = %i(system_name title path draft section_id layout_name layout_id
                      liquid_enabled handler content_type).freeze

  wrap_parameters :template, include: ALLOWED_PARAMS,
                             format: [:json, :xml, :multipart_form, :url_encoded_form]

  before_action :find_template, :except => [ :index, :create ]

  before_action :can_destroy, only: :destroy

  ##=  api("/admin/api/cms/templates.xml", 'List[short-template]') {
  ##=    GET('List all templates') {
  ##=      paginated
  ##=      requires_access_token
  ##=    }
  def index
    templates = cms_templates.paginate(pagination_params)
    respond_with(templates, short: true, representer: CMS::TemplatesRepresenter)
  end

  ##=    POST('Create a template') {
  ##=      description 'Create partial, layout or page'
  ##=      requires_access_token
  ##=      param 'type', choices: [ 'page', 'layout', 'partial'], required: true
  ##=      template_model_params
  ##=    }
  ##=  }
  ##=
  def create
    type = params.require('type')

    collections = { page: current_account.pages,
                    partial: current_account.partials,
                    layout: current_account.layouts }

    if type && (collection = collections[type.to_sym])
      template = collection.new(cms_template_params)
      if template.respond_to?(:section)
        template.section ||= find_section
      end
      template.save
      respond_with(template)
    else
      render_error "Unknown template type '#{type}'", status: :not_acceptable
    end
  end

  ##=   api("/admin/api/cms/templates/{id}.xml", 'template') {
  ##=     GET('View template') {
  ##=       requires_access_token
  ##=       id 'ID of the template'
  ##=     }
  ##=
  def show
    respond_with(@template)
  end

  ##=     PUT('Update template') {
  ##=       description 'Update [builtin] page, partial or layout and draft content.'
  ##=       requires_access_token
  ##=       id 'ID of the template'
  ##=       template_model_params
  ##=     }
  ##=
  def update
    if @template.respond_to?(:section)
      @template.section ||= find_section
    end
    @template.update_attributes(cms_template_params)
    respond_with(@template)
  end

  ##=     DELETE('Delete template') {
  ##=       description 'Delete page, partial or layout.'
  ##=       requires_access_token
  ##=       id 'ID of the template'
  ##=     }
  ##=   }
  ##=
  def destroy
    @template.destroy
    respond_with(@template)
  end

  ##=   api("/admin/api/cms/templates/{id}/publish.xml", 'template') {
  ##=     PUT('Publish template') {
  ##=       description 'The current draft will be published and visible by all users.'
  ##=       requires_access_token
  ##=       id 'ID of the template'
  ##=     }
  ##=   }
  def publish
    @template.publish!
    respond_with @template
  end

  protected

  def find_template
    @template = cms_templates.find(params[:id])
  end

  def cms_template_params
    attrs = params.require(:template).permit(*ALLOWED_PARAMS)

    set_layout_by(:layout_name, :find_by_system_name, attrs)
    set_layout_by(:layout_id, :find_by_id, attrs)

    attrs
  end

  private

  def can_destroy
    head :locked unless @template.respond_to?(:destroy)
  end

  def cms_templates
    current_account.templates.but(CMS::EmailTemplate, CMS::Builtin::LegalTerm).order(:id)
  end

  def find_section
    scope = current_account.sections
    scope.find_by_id(params[:section_id]) || scope.find_by_system_name(params[:section_name]) || scope.root
  end

  def set_layout_by(attr_name, finder, attrs)
    if attrs.key?(attr_name)
      attrs[:layout] = if name = attrs[attr_name].presence
        current_account.layouts.send(finder,name)
                       end
    end
  end

end
