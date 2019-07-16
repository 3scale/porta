# frozen_string_literal: true

class ProxyPresenter < SimpleDelegator
  delegate :default_api_backend, to: :backend_api
  class << self
    delegate :model_name, to: 'Proxy'
  end
end
