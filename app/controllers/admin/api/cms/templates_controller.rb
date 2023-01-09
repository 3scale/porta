class Admin::Api::CMS::TemplatesController < Admin::Api::CMS::BaseController
  ##~ sapi = source2swagger.namespace("CMS API")
  ##~ @parameter_template_id = { :name => "id", :description => "ID of the template", :dataType => "int", :required => true, :paramType => "path" }

  ALLOWED_PARAMS = %i[type system_name title path draft liquid_enabled handler content_type].freeze

  wrap_parameters :template, include: ALLOWED_PARAMS,
                             format: [:json, :xml, :multipart_form, :url_encoded_form]

  before_action :find_template, :except => [ :index, :create ]

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
    cms_params = cms_template_params
    type = cms_params.delete('type')

    collections = { page: current_account.pages,
                    partial: current_account.partials,
                    layout: current_account.layouts }

    if type && (collection = collections[type.to_sym])
      template = collection.new(cms_params)
      template.section ||= find_section if template.respond_to?(:section)
      template.layout ||= find_layout if template.respond_to?(:layout)
      template.save
      respond_with(template)
    else
      render_error "Unknown template type '#{type}'", status: :not_acceptable
    end
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
    if @template.respond_to?(:section)
      section = find_section
      @template.section = section if section.present?
    end
    if @template.respond_to?(:layout)
      layout = find_layout
      @template.layout = layout if layout.present?
    end
    @template.update_attributes(cms_template_params)
    respond_with(@template)
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
    params.require(:template).permit(*ALLOWED_PARAMS)
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

  def find_layout
    scope = current_account.layouts
    scope.find_by_id(params[:layout_id]) || scope.find_by_system_name(params[:layout_name])
  end

end
