# frozen_string_literal: true

module AccountIndex
  module ForAccount

    extend ActiveSupport::Concern

    included do
      after_commit :index_account
    end

    def sphinx_usernames
      users.pluck(:username).join(' ')
    end

    def sphinx_full_names
      users.pluck(:first_name, :last_name).flatten.join(' ')
    end

    def sphinx_emails
      users.pluck(:email).join(' ')
    end

    def sphinx_user_keys
      bought_cinstances.pluck(:user_key).join(' ')
    end

    def sphinx_app_ids
      bought_cinstances.pluck(:application_id).join(' ')
    end

    def sphinx_app_names
      bought_cinstances.pluck(:name).join(' ')
    end

    def sphinx_user_ids
      user_ids.join(' ')
    end

    protected

    def index_account
      SphinxAccountIndexationWorker.perform_later(self.class, id) unless master?
    end
  end

  module ForDependency
    extend ActiveSupport::Concern

    included do
      # index account even when dep is destroyed
      after_commit :index_account
    end

    protected

    def account_for_sphinx
      raise NoMethodError, "Please define `#account_for_sphinx` method"
    end

    def index_account
      SphinxAccountIndexationWorker.perform_later(Account, account_for_sphinx)
    end
  end
end
