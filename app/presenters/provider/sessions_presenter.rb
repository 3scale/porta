# frozen_string_literal: true

class Provider::SessionsPresenter
  def initialize(domain_account)
    @domain_account = domain_account
  end

  def show_username_password_related_content?
    !@domain_account.heroku? && !@domain_account.settings.enforce_sso?
  end
end
