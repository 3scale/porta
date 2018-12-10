# frozen_string_literal: true

module BuyerDomainConstraint
  module_function

  def matches?(request)
    request.extend(ThreeScale::DevDomain::Request) if ThreeScale::DevDomain.enabled?
    Account.without_deleted.exists?(:domain => request.host) && !MasterDomainConstraint.matches?(request)
  end
end

class DomainConstraint
  def initialize(domain)
    @domain = domain
  end

  def matches?(request)
    request.host == @domain
  end
end

module ProviderDomainConstraint
  module_function

  def matches?(request)
    request.extend(ThreeScale::DevDomain::Request) if ThreeScale::DevDomain.enabled?

    with_deleted = AuthenticatedSystem::Request.new(request).zync?
    Account.without_deleted(!with_deleted).exists?(:self_domain => request.host)
  end
end

module MasterDomainConstraint
  module_function

  def matches?(request)
    request.extend(ThreeScale::DevDomain::Request) if ThreeScale::DevDomain.enabled?
    return true if ThreeScale.master_on_premises?

    master = Account.master
    master.admin_domain == request.host or master.domain == request.host
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
