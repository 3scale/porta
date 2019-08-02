# frozen_string_literal: true

class Signup::ProviderAccountManager < Signup::AccountManager
  self.account_builder = lambda do |account|
    account.provider = true
    account.sample_data = true
    account.email_all_users = true
    account.generate_domains
    account
  end

  def self.set_provider_constraints(provider, application_plan)
    return if provider.partner.present?
    provider.create_provider_constraints application_plan.limits
  end

  private

  def persist!(result, plans, defaults)
    account = result.account
    account.signup_mode! # don't create service or app by callback; validate subdomain instead of domain
    ::Signup::ImpersonationAdminBuilder.build(account: account)
    result.save!
    update_tenant_ids(account)
    contract_plans_and_create_service(account, plans, defaults)
    SignupWorker.enqueue(account)
  end

  def contract_plans_and_create_service(account, plans, defaults)
    create_contract_plans_for_account!(account, plans, defaults)
    account.services.create! name: 'API'
    set_switches_and_limits(account, plans.application_plan)
  end

  def set_switches_and_limits(account, application_plan)
    if ThreeScale.config.onpremises
      account.force_upgrade_to_provider_plan!(application_plan)
    else
      Signup::ProviderAccountManager.set_provider_constraints(account, application_plan)
    end
  end

  def update_tenant_ids(account)
    account_id = account.id
    account.users.scope.update_all(tenant_id: account_id)
    account.fields_definitions.update_all "tenant_id = #{account_id}"
  end
end
