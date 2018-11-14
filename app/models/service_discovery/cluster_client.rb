# frozen_string_literal: true

require 'kubeclient'

module ServiceDiscovery
  class ClusterClient
    class ClusterClientError < StandardError; end

    class ResourceNotFound < ClusterClientError
      def initialize(resource_type, name, namespace, labels = {})
        resource_name = namespace.present? ? "#{namespace}/#{name}" : name
        error_message = "Resource #{resource_name} of kind #{resource_type.to_s.camelize} not found"
        error_message += " with labels #{labels}" if labels.present?
        super(error_message)
      end
    end

    def initialize(opts = {})
      service_discovery_configs = ThreeScale.config.service_discovery.to_h
      options = opts.reverse_merge(service_discovery_configs.slice(:server_scheme, :server_host, :server_port, :bearer_token))

      @k8s = self.class.build_k8s_client(options)
      @ocp = self.class.build_ocp_client(options)
    end

    attr_reader :k8s, :ocp

    def method_missing(method_sym, *args, &block)
      client = client_that_responds_to(method_sym)
      return client.public_send(method_sym, *args, &block) if client
      super
    end

    def respond_to_missing?(method_sym, include_private = false)
      clients_respond_to?(method_sym) || super
    end

    def namespaces
      # 'view' cluster-role permission is required
      get_namespaces.map { |resource| ClusterNamespace.new(resource, self) }
    end

    def projects
      get_projects.map { |resource| ClusterProject.new(resource, self) }
    end

    def services(namespace: nil, labels: {})
      within_namespace(namespace, with_labels: labels) do |search_criteria|
        get_services(search_criteria).map { |resource| ClusterService.new(resource, self) }
      end
    end

    def routes(namespace: nil, labels: {})
      within_namespace(namespace, with_labels: labels) do |search_criteria|
        get_routes(search_criteria).map { |resource| ClusterRoute.new(resource, self) }
      end
    end

    def find_namespace_by(name:)
      find_resource(:namespace, name)
    end

    def find_project_by(name:)
      find_resource(:project, name)
    end

    def find_service_by(name:, namespace:)
      find_resource(:service, name, namespace)
    end

    def find_route_by(name:, namespace:)
      find_resource(:route, name, namespace)
    end

    def discoverable_services(namespace: nil, labels: {})
      services(namespace: namespace, labels: labels.merge(ClusterService.discovery_label_selector)).select(&:discoverable?)
    end

    def find_discoverable_service_by(name:, namespace:)
      cluster_service = find_service_by(namespace: namespace, name: name)
      raise_not_found('Service', name, namespace) unless cluster_service.discoverable?
      cluster_service
    end

    def projects_with_discoverables
      # Less efficient than fetching all discoverable services (unscoped) and then selecting the unique namespaces,
      # but it allows using an user's (or user-level service account's) token to fetch the list of projects
      projects.select { |project| discoverable_services(namespace: project.namespace).any? }
    end

    DEFAULT_CLUSTER_SCHEME = 'https'
    DEFAULT_CLUSTER_HOST = 'kubernetes.default.svc.cluster.local'
    DEFAULT_CLUSTER_PORT = 443

    def self.build_api_endpoint(options = {})
      server_scheme = options[:server_scheme] || DEFAULT_CLUSTER_SCHEME
      server_host = options[:server_host] || DEFAULT_CLUSTER_HOST
      server_port = options[:server_port] || DEFAULT_CLUSTER_PORT

      api_path = options[:api_path].presence

      "#{server_scheme}://#{server_host}:#{server_port}/#{api_path}"
    end

    def self.build_client_options(options = {})
      [
        build_api_endpoint(options),
        'v1',
        ssl_options: { verify_ssl: OpenSSL::SSL::VERIFY_NONE },
        auth_options: { bearer_token: options[:bearer_token] }
      ]
    end

    def self.build_ocp_client(options = {})
      Kubeclient::Client.new(*build_client_options(options.merge(api_path: 'oapi')))
    end

    def self.build_k8s_client(options = {})
      Kubeclient::Client.new(*build_client_options(options.merge(api_path: 'api')))
    end

    protected

    def within_namespace(namespace, with_labels: {})
      search_criteria = {}
      search_criteria[:namespace] = namespace.presence

      if with_labels.present?
        label_selector = with_labels.map { |label, value| "#{label}=#{value}" }.join(',')
        search_criteria[:label_selector] = label_selector
      end

      yield search_criteria
    end

    def find_resource(type, name, namespace = nil)
      begin
        args = [name, namespace.presence].compact
        resource_data = public_send("get_#{type.to_s.downcase}", *args)
        raise_not_found(type, name, namespace) unless resource_data
      rescue KubeException => exception
        handle_kube_exception(exception, type, name, namespace)
      end

      klass = "ServiceDiscovery::Cluster#{type.to_s.camelize}".constantize
      klass.new(resource_data, self)
    end

    def handle_kube_exception(exception, *args)
      case exception.error_code
      when 404
        raise_not_found(*args)
      else
        raise ClusterClientError, exception.to_s
      end
    end

    def raise_not_found(resource_type, resource_name, namespace = nil, fields = {})
      raise ResourceNotFound.new(resource_type, resource_name, namespace, fields)
    end

    def client_that_responds_to(method_sym)
      [ocp, k8s].each do |client|
        client_responds_to_method = client.respond_to?(method_sym)
        return client if client_responds_to_method
      end

      nil
    end

    def clients_respond_to?(method_sym)
      client_that_responds_to(method_sym).present?
    end
  end
end
