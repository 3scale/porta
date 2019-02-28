# frozen_string_literal: true

class ApiDocs::ServicesController < FrontendController

  class ApiFileDoesNotExist < StandardError; end

  delegate :api_files, :apis, :exclude_plan_endpoints, to: 'self.class'
  delegate :master_on_premises?, to: :current_account, allow_nil: true
  delegate :master?, to: :current_account, allow_nil: true

  class << self
    def forbidden_apis
      ThreeScale.master_on_premises? ? %i[billing_api] : []
    end

    def api_files
      API_FILES.except(*forbidden_apis)
    end

    def apis(&block)
      accept_api = block_given? ? block : proc { true }
      APIS.select { |api| !forbidden_apis.include?(api.fetch(:system_name)) && accept_api.call(api) }
    end

    def verify_accessible_api_files_exist!
      apis.each do |api|
        file_path = ApiFile.new(*api.values_at(:name, :system_name)).file_path
        raise(ApiFileDoesNotExist, "file #{file_path} does not exist") unless File.exist?(file_path)
      end
    end

    def exclude_plan_endpoints(apis)
      apis.select { |api| api['path'].exclude?('plan') }
    end
  end

  class ApiFile

    attr_reader :name, :system_name

    def initialize(name, system_name)
      @name = name
      @system_name = system_name.to_sym
    end

    def json
      parsed_content = JSON.parse(file_content)
      parsed_content['basePath'] = backend_base_host if backend_api?

      parsed_content
    end

    def file_path
      Rails.root.join('doc', 'active_docs', "#{file_name}.json")
    end

    private

    def file_name
      if onpremises_version? && onpremises_version_preferred?
        "#{name} (on-premises)"
      else
        name
      end
    end

    def backend_base_host
      backend_config = System::Application.config.backend_client

      [
        backend_config[:public_url],
        backend_config[:url],
        "https://#{backend_config[:host]}"
      ].find(&:presence)
    end

    ONPREMISES_VERSION = %i[service_management_api].freeze
    BACKEND_APIS = %i[service_management_api].freeze

    def onpremises_version?
      ONPREMISES_VERSION.include?(system_name)
    end

    def onpremises_version_preferred?
      Rails.application.config.three_scale.onpremises_api_docs_version
    end

    def backend_api?
      BACKEND_APIS.include?(system_name)
    end

    def file_content
      File.exist?(file_path) ? File.read(file_path) : '{}'
    end
  end

  API_SYSTEM_NAMES = %i[service_management_api account_management_api analytics_api billing_api master_api policy_registry_api].freeze

  APIS = API_SYSTEM_NAMES.map do |system_name|
    {
      name:        I18n.t("admin.api_docs.services.names.#{system_name}"),
      system_name: system_name,
      description: '',
      path:        "/api_docs/services/#{system_name}.json"
    }
  end.freeze

  verify_accessible_api_files_exist!

  API_FILES = APIS.each_with_object({}) do |api, files|
    api_json = ApiFile.new(api[:name], api[:system_name]).json
    files[api[:system_name]] = api_json
  end.freeze

  def index
    render json: { host: '', apis: apis(&method(:allowed_api?)) }
  end

  def show
    system_name = params[:id].to_sym
    api_file = (api_files.fetch(system_name) { raise ActiveRecord::RecordNotFound }).dup
    api_file['apis'] = exclude_plan_endpoints(api_file['apis']) if master_on_premises?

    render json: api_file
  end

  private

  def allowed_api?(api)
    case api[:system_name]
    when :master_api
      master?
    when :policy_registry_api
      current_account.tenant? && provider_can_use?(:policy_registry)
    else
      true
    end
  end
end
