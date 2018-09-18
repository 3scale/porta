class DeveloperPortal::Swagger::SpecController < DeveloperPortal::BaseController

  skip_before_action :login_required

  clear_respond_to
  respond_to :json

  # This is only for 1.2 specs
  def index
    apis = site_account.api_docs_services
      .published
      .with_system_names((params[:services] || "").split(","))
      .select{ |api| api.specification.swagger_1_2? }

    respond_with({
      swaggerVersion: "1.2",
      apis: apis.map!{ |service| swagger_spec_for(service) },
      basePath: "#{request.protocol}#{request_target_host}"
    })
  end

  # TODO:
  #   - if basePath ends with / and in operations path starts with / then the url will contain //
  #   and somehow the call fails somewhere in the chain (api-docs-proxy/apache/nginx)
  def show

    active_doc = site_account.api_docs_services.published.find_by_id_or_system_name params[:id]

    json = if active_doc.specification.swagger_2_0?
      active_doc.specification.as_json
           else
      ThreeScale::Swagger::Translator.translate! active_doc.body
           end

    respond_with json
  end

  private

    # This returns a Resource Object
    # https://github.com/wordnik/swagger-spec/blob/master/versions/1.2.md#512-resource-object
    def swagger_spec_for service
      {
        description: service.description.nil? ? service.name : service.description,
        path: "#{swagger_spec_path(service.system_name)}.{format}"
      }
    end
end
