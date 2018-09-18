class Onboarding::ApiForm < Reform::Form
  include ThreeScale::Reform
  include Composition

  ECHO_API_BACKEND = "https://#{Proxy::ECHO_API_HOST}".freeze

  model :service

  property :name, on: :service
  property :backend, on: :proxy, from: :api_backend
  property :test_path, on: :proxy, from: :api_test_path

  validates :name, :backend, presence: true

  def initialize(*)
    super

    self.backend = nil if just_created?(proxy)
    self.name = nil if just_created?(service)
  end

  def backend
    (api = super) ? URI(api) : api
  rescue URI::InvalidURIError
    api
  end

  def example_backend
    ECHO_API_BACKEND
  end

  protected

  def just_created?(model)
    model.created_at == model.updated_at
  end

  def service
    model.fetch(:service)
  end

  def proxy
    model.fetch(:proxy)
  end
end
