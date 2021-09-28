# frozen_string_literal: true

module Account::ProviderDomains
  extend ActiveSupport::Concern

  included do
    include ThreeScale::DomainSubstitution::Account

    with_options :if => :validate_domains? do |provider|
      provider.validate :domain_uniqueness, :self_domain_uniqueness, :domain_not_self_domain

      provider.validates_presence_of :domain, :unless => :signup?
      provider.validates_presence_of :self_domain, :unless => :signup?

      # special banned domains
      BANNED_DOMAINS = (Rails.application.simple_try_config_for(:banned_domains) || []).freeze
      provider.validates_exclusion_of :domain, :in => BANNED_DOMAINS, :allow_blank => true, :message => "has already been taken"
      provider.validates_exclusion_of :self_domain, :in => BANNED_DOMAINS, :allow_blank => true, :message => "has already been taken"


      # this is for signup (we care about subdomain)
      provider.validates_presence_of :subdomain, :if => :signup?
      provider.validates_presence_of :self_subdomain, :if => :signup?

      provider.validates_format_of :subdomain, :with => /\A[a-z0-9](?:[a-z0-9\-]*?[a-z0-9])?\z/i,
                                   :allow_blank => true, :message => :domain

      provider.validates_format_of :subdomain, :with => /\A[^A-Z]*\z/, :message => "must be downcase", :on => :create, :allow_blank => true, :if => :signup?
      provider.validates_format_of :domain, :with => /\A[^A-Z]*\z/, :message => "must be downcase", :allow_blank => true, :unless => :signup?
      provider.validates_format_of :self_domain, :with => /\A[^A-Z]*\z/, :message => "must be downcase", :allow_blank => true, :unless => :signup?

    end

    scope :by_domain, ->(domain) { where(domain: domain) }
    scope :by_self_domain, ->(domain) { where(self_domain: domain) }
    scope :by_admin_domain, ->(domain) {
      table = table_name
      where("(#{table}.self_domain = :domain) OR (#{table}.self_domain IS NULL AND provider_accounts_accounts.domain = :domain)",
            { :domain => domain })
      .joins(:provider_account)
      .readonly(false)
    }

    after_save :publish_domain_events, if: :domains_changed?
    before_destroy :publish_domain_events, if: :provider?
  end

  module ClassMethods
    def find_by_domain(domain)
      return false if domain.blank?

      find_by(domain: domain)
    end

    def find_by_domain!(domain)
      find_by_domain(domain) || # rubocop:disable Rails/DynamicFindBy
        raise(ActiveRecord::RecordNotFound, "Couldn't find #{name} with domain=#{domain.inspect}")
    end

    def is_domain?(domain)
      return if domain.blank?
      providers.where(:domain => domain).exists?
    end

    def is_admin_domain?(domain)
      providers.where(:self_domain => domain).exists?
    end

    def is_master_domain?(domain)
      return true if ThreeScale.master_on_premises?
      master.domain == domain or master.self_domain == domain
    end

    def same_domain(domain)
      # TODO: case insensitive
      where(["(domain = :domain OR self_domain = :domain)", {:domain => domain}])
    end
  end

  def domains_changed?
    saved_change_to_attribute?(:domain) || saved_change_to_attribute?(:self_domain)
  end

  def publish_domain_events
    ::Domains::ProviderDomainsChangedEvent.create_and_publish!(self)
    nil
  end

  def generate_domains
    return if domains_present?
    return if org_name.blank? && subdomain.blank?

    generate_domains!
  end

  def generate_domains!
    domains_builder_params = { current_subdomain: subdomain.presence, org_name: org_name, invalid_subdomain_condition: method(:subdomain_exists?) }
    domains_builder = master? ? Signup::MasterDomainsBuilder.new(**domains_builder_params) : Signup::DomainsBuilder.new(**domains_builder_params)
    assign_domains(domains_builder.generate)
  end

  def domains_present?
    domain.present? && self_domain.present?
  end

  def subdomain=(name)
    self.domain = if name.present?
                    [name, superdomain].join('.')
                  else
                    name
                  end
  end

  def assign_domains(domains)
    self.subdomain = domains.subdomain
    self.self_subdomain = domains.self_subdomain
  end

  def subdomain
    subdomain_from(domain)
  end

  def superdomain
    ThreeScale.config.superdomain
  end

  def dedicated_domain
    superdomain = provider_account&.superdomain

    if superdomain && !domain.nil? && domain.ends_with?(superdomain)
      nil
    else
      domain
    end
  end

  attr_writer :dedicated_domain

  def self_subdomain=(name)
    self.self_domain = if name.present?
                         [name, superdomain].join('.')
                       else
                         name
                       end
  end

  def self_subdomain
    subdomain_from(self_domain)
  end

  def self.unique?(attr:, val:, scope: all)
    scope = case attr
            when :domain, :self_domain
              scope.same_domain(val)
            else
              scope.where(attr => val)
            end

    !scope.exists?
  end
  private

  def validate_domains?
    provider? and !master?
  end

  def subdomain_from(domain)
    domain.to_s[/\A(.+)\.#{Regexp.quote(superdomain)}\z/, 1]
  end

  def subdomain_unique?(subdomain:)
    subdomains = %W[#{subdomain}.#{superdomain} #{subdomain}-admin.#{superdomain}]
    subdomains.all? { |domain| unique?(:domain, domain) }
  end

  def subdomain_exists?(subdomain:)
    !subdomain_unique?(subdomain: subdomain)
  end

  def unique?(attr, val = self[attr])
    scope = new_record? ? Account.all : Account.where.not(id: id)
    Account::ProviderDomains.unique?(attr: attr, val: val, scope: scope)
  end

  def domain_uniqueness
    unless unique?(:domain)
      if subdomain
        errors.add(:subdomain, :taken)
      else
        errors.add(:domain, :taken)
      end
    end
  end

  def self_domain_uniqueness
    unless unique?(:self_domain)
      if subdomain
        errors.add(:self_subdomain, :taken)
      else
        errors.add(:self_domain, :taken)
      end
    end
  end

  def domain_not_self_domain
    if domain && self_domain && domain == self_domain
      if subdomain
        errors.add(:subdomain, :same)
        errors.add(:self_subdomain, :same)
      else
        errors.add(:domain, :same)
        errors.add(:self_domain, :same)
      end
    end
  end

end
