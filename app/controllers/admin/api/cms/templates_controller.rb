class Admin::Api::CMS::TemplatesController < Admin::Api::CMS::BaseController

  AVAILABLE_PARAMS = %i[system_name title path draft liquid_enabled handler content_type section_id layout_id].freeze
  ALLOWED_PARAMS = {
    page: %i[title path content_type system_name section_id layout_id liquid_enabled draft handler],
    'builtin-page': %i[layout_id draft],
    layout: %i[system_name draft title liquid_enabled],
    partial: %i[system_name draft],
    'builtin-partial': %i[draft],
  }.freeze

  wrap_parameters :template, include: AVAILABLE_PARAMS,
                             format: %i[json multipart_form url_encoded_form]

  forbid_extra_params :reject, whitelist: %i[id page per_page type layout_name section_name content]

  before_action :find_template, except: %i[index create]

  # Template List
  # GET /admin/api/cms/templates.json
  def index
    templates = cms_templates.scope_search(search).paginate(pagination_params)
    short = !content?
    respond_with(templates, representer: CMS::TemplatesRepresenter, user_options: { short: short })
  end

  # Template Create
  # POST /admin/api/cms/templates.json
  def create
    template = Admin::Api::CMS::TemplateService::Create.call(current_account, params, cms_template_params)
    respond_with(template)
  rescue Admin::Api::CMS::TemplateService::TemplateServiceError => exception
    render_error exception.message, status: :unprocessable_entity
  end

  # Template Read
  # GET /admin/api/cms/templates/{id}.json
  def show
    respond_with(@template)
  end

  # Template Update
  # PUT /admin/api/cms/templates/{id}.json
  def update
    Admin::Api::CMS::TemplateService::Update.call(current_account, params, cms_template_params, @template)
    respond_with(@template)
  rescue Admin::Api::CMS::TemplateService::TemplateServiceError => exception
    render_error exception.message, status: :unprocessable_entity
  end

  # Template Delete
  # DELETE /admin/api/cms/templates/{id}.json
  def destroy
    Admin::Api::CMS::TemplateService::Destroy.call(@template)
    respond_with(@template)
  rescue Admin::Api::CMS::TemplateService::TemplateServiceError => exception
    render_error exception.message, status: :unprocessable_entity
  end

  # Template Publish
  # PUT /admin/api/cms/templates/{id}/publish.json
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

  def cms_templates
    current_account.templates.but(CMS::EmailTemplate, CMS::Builtin::LegalTerm).order(:id)
  end

  def content?
    params[:content] == "true"
  end
end
