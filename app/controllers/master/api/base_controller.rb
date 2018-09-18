# frozen_string_literal: true

class Master::Api::BaseController < Master::BaseController
  include ApiAuthentication::ByProviderKey
  include ApiSupport::PrepareResponseRepresenter
  include ApiSupport::Params
  include SiteAccountSupport

  before_action :authenticate!

  private

  def provider_key_param_name
    :api_key
  end

  def authenticate!
    render plain: 'unauthorized', status: 401 unless logged_in?
  end

  ## Defining common parameters

  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token"}
  ##~ @parameter_system_name_by_name = {:name => "system_name", :description => "System Name of the object to be created. System names cannot be modified after creation, they are used as the key to identify the objects.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_page = {:name => "page", :description => "Page in the paginated list. Defaults to 1.", :dataType => "int", :paramType => "query", :defaultValue => "1"}
  ##~ @parameter_per_page = {:name => "per_page", :description => "Number of results per page. Default and max is 500.", :dataType => "int", :paramType => "query", :defaultValue => "500"}

  ## Extra

  ##~ @parameter_extra = {:name => "additional_fields", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Additional fields have to be defined by name and value (i.e &name=value). You can add as many as you want. Additional fields are the custom fields declared in 'Settings >> Fields Definitions' on your API Admin Portal. Typical examples are 'url', 'country', etc. Please check your Fields Definitions to get the list of all your custom fields."}
  ##~ @parameter_extra_short = {:name => " ", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Extra parameters"}
end
