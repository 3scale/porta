class Admin::Api::CMS::TemplatesController < Admin::Api::CMS::BaseController
  ##~ sapi = source2swagger.namespace("CMS API")
  ##~ @parameter_template_id = { :name => "id", :description => "ID of the template", :dataType => "int", :required => true, :paramType => "path" }

  AVAILABLE_PARAMS = %i[system_name title path draft liquid_enabled handler content_type section_id layout_id].freeze
  ALLOWED_PARAMS = {
    page: %i[title path content_type system_name section_id layout_id liquid_enabled draft handler],
    'builtin-page': %i[layout_id draft],
    layout: %i[system_name draft title liquid_enabled],
    partial: %i[system_name draft],
    'builtin-partial': %i[draft],
  }.freeze

  wrap_parameters :template, include: AVAILABLE_PARAMS,
                             format: %i[json xml multipart_form url_encoded_form]

  before_action :find_template, except: %i[index create]

  before_action :can_destroy, only: :destroy

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/templates.xml"
  ##~ e.responseClass = "List[short-template]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Template List"
  ##~ op.description = "List all templates"
  ##~ op.group = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  def index
    templates = cms_templates.paginate(pagination_params)
    respond_with(templates, short: true, representer: CMS::TemplatesRepresenter)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Template Create"
  ##~ op.description = "Create partial, layout or page"
  ##~ op.group = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "type", :paramType => "query", :required => true, :allowableValues => { :valueType => "LIST", :values => ["page", "layout", "partial"]  }
  ##~ op.parameters.add :name => "system_name", :description => "Human readable and unique identifier", :paramType => "query"
  ##~ op.parameters.add :name => "title", :description => "Title of the template", :paramType => "query"
  ##~ op.parameters.add :name => "path", :description => "URI of the page", :paramType => "query"
  ##~ op.parameters.add :name => "draft", :description => "Text content of the template (you have to publish the template)", :paramType => "query"
  ##~ op.parameters.add :name => "section_name", :description => "system name of a section", :paramType => "query", :type => "string"
  ##~ op.parameters.add :name => "section_id", :description => "ID of a section (valid only for pages)", :paramType => "query", :type => "int", :default => "root section id"
  ##~ op.parameters.add :name => "layout_name", :description => "system name of a layout (valid only for pages)", :paramType => "query", :type => "string"
  ##~ op.parameters.add :name => "layout_id", :description => "ID of a layout - overrides layout_name", :paramType => "query", :type => "int"
  ##~ op.parameters.add :name => "liquid_enabled", :description => "liquid processing of the template content on/off", :paramType => "query", :type => "boolean"
  ##~ op.parameters.add :name => "handler", :paramType => "query", :description => "text will be processed by the handler before rendering", :required => false, :allowableValues => { :valueType => "LIST", :values => ["textile", "markdown"]  }
  def create
    template = Admin::Api::CMS::TemplateService::Create.call(current_account, params, cms_template_params)
    respond_with(template)
  rescue Admin::Api::CMS::TemplateService::TemplateServiceError => exception
    render_error exception.message, status: :unprocessable_entity
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/templates/{id}.xml"
  ##~ e.responseClass = "template"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Template Read"
  ##~ op.description = "View template"
  ##~ op.group       = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_template_id
  def show
    respond_with(@template)
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "Template Update"
  ##~ op.description = "Update [builtin] page, partial or layout and draft content."
  ##~ op.group       = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_template_id
  ##~ op.parameters.add :name => "system_name", :description => "Human readable and unique identifier", :paramType => "query"
  ##~ op.parameters.add :name => "title", :description => "Title of the template", :paramType => "query"
  ##~ op.parameters.add :name => "path", :description => "URI of the page", :paramType => "query"
  ##~ op.parameters.add :name => "draft", :description => "Text content of the template (you have to publish the template)", :paramType => "query"
  ##~ op.parameters.add :name => "section_name", :description => "system name of a section", :paramType => "query", :type => "string"
  ##~ op.parameters.add :name => "section_id", :description => "ID of a section (valid only for pages)", :paramType => "query", :type => "int", :default => "root section id"
  ##~ op.parameters.add :name => "layout_name", :description => "system name of a layout (valid only for pages)", :paramType => "query", :type => "string"
  ##~ op.parameters.add :name => "layout_id", :description => "ID of a layout - overrides layout_name", :paramType => "query", :type => "int"
  ##~ op.parameters.add :name => "liquid_enabled", :description => "liquid processing of the template content on/off", :paramType => "query", :type => "boolean"
  ##~ op.parameters.add :name => "handler", :paramType => "query", :description => "text will be processed by the handler before rendering", :required => false, :allowableValues => { :valueType => "LIST", :values => ["textile", "markdown"]  }
  def update
    Admin::Api::CMS::TemplateService::Update.call(current_account, params, cms_template_params, @template)
    respond_with(@template)
  rescue Admin::Api::CMS::TemplateService::TemplateServiceError => exception
    render_error exception.message, status: :unprocessable_entity
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "DELETE"
  ##~ op.summary     = "Template Delete"
  ##~ op.description = "Delete page, partial or layout."
  ##~ op.group       = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_template_id
  def destroy
    @template.destroy
    respond_with(@template)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/templates/{id}/publish.xml"
  ##~ e.responseClass = "template"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "Template Publish"
  ##~ op.description = "The current draft will be published and visible by all users."
  ##~ op.group       = "cms_templates"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_template_id
  def publish
    @template.publish!
    respond_with @template
  end

  protected

  def find_template
    @template = cms_templates.find(params[:id])
  end

  def cms_template_params
    params.require(:template).permit(*allowed_type_params)
  end

  private

  def allowed_type_params
    ALLOWED_PARAMS[template_type]
  end

  def template_type
    return params[:type].parameterize.to_sym if params[:type].present?

    @template.class.name[5..-1].parameterize.to_sym if @template.present?
  end

  def can_destroy
    head :locked unless @template.respond_to?(:destroy)
  end

  def cms_templates
    current_account.templates.but(CMS::EmailTemplate, CMS::Builtin::LegalTerm).order(:id)
  end
end
