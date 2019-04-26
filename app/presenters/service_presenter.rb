# frozen_string_literal: true

class ServicePresenter < Delegator
  def initialize(service)
    @service = service
  end

  attr_reader :service
  alias_method :__getobj__, :service

  def backend_apis
    [Services::BackendApiPresenter.new(service)]
  end
end
