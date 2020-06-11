# frozen_string_literal: true

ThinkingSphinx::Index.define(:account, with: :real_time) do
  indexes :org_name, as: :name
  indexes sphinx_usernames, as: :username
  indexes sphinx_full_names, as: :user_full_name
  indexes sphinx_emails, as: :email
  indexes sphinx_user_keys, as: :user_key
  indexes sphinx_app_ids, as: :app_id
  indexes sphinx_app_names, as: :app_name
  indexes :id, as: :account_id
  indexes sphinx_user_ids, as: :user_id

  set_property field_weights: { name: 2 }

  # set_property(group_concat_max_len: 32_000 - 1) if System::Database.mysql?

  has :provider_account_id, type: :integer
  has :tenant_id, type: :integer
  has :state, type: :string

  # if System::Database.oracle?
  #   # Need to add the group by otherwise it will complain about ORA-00979 not a Group By function error
  #   group_by "accounts.state"
  # end

  # where sanitize_sql(['COALESCE(accounts.master, ?) = ?', false, false])
end

module AccountIndex
  module ForAccount

    extend ActiveSupport::Concern

    included do
      after_save :index_account
    end

    def sphinx_usernames
      users.pluck(:username).join(' ')
    end

    def sphinx_full_names
      users.select(:first_name, :last_name)
        .pluck(:first_name, :last_name)
        .flatten.join(' ')
    end

    def sphinx_emails
      users.select(:email).pluck(:email).join(' ')
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
      SphinxIndexationWorker.perform_later(self) unless master?
    end
  end

  module ForDependency
    extend ActiveSupport::Concern

    included do
      after_save :index_account
      after_destroy :index_account
    end

    protected

    def account_for_sphinx
      raise NoMethodError, "Please define `#account_for_sphinx` method"
    end

    def index_account
      return unless account_for_sphinx&.persisted?
      SphinxIndexationWorker.perform_later(account_for_sphinx)
    end
  end
end
