# frozen_string_literal: true

module BuyerDomainConstraint
  module_function

  def matches?(request)
    Account.without_deleted.exists?(:domain => request.internal_host) && !MasterDomainConstraint.matches?(request)
  end
end

class DomainConstraint
  def initialize(domain)
    @domain = domain
  end

  def matches?(request)
    request.internal_host == @domain
  end
end

module ProviderDomainConstraint
  module_function

  def matches?(request)
    with_deleted = AuthenticatedSystem::Request.new(request).zync?
    Account.tenants.without_deleted(!with_deleted).exists?(self_domain: request.internal_host)
  end
end

module MasterDomainConstraint
  module_function

  def matches?(request)
    return true if ThreeScale.master_on_premises?

    master = Account.master
    host = request.internal_host
    master.external_admin_domain == host or master.external_domain == host
  end
end

module MasterOrProviderDomainConstraint
  module_function

  def matches?(request)
    ProviderDomainConstraint.matches?(request) || MasterDomainConstraint.matches?(request)
  end
end

module LoggedInConstraint
  module_function

  def matches?(request)
    AuthenticatedSystem::Request.new(request).authenticated?
  end
end

class ParameterConstraint
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def matches?(request)
    request.params.key?(name)
  end
end

class PortConstraint
  def initialize(port)
    @port = port.to_s
  end

  def matches?(request)
    request.port.to_s == @port
  end
end
