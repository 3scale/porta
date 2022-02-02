# frozen_string_literal: true

class EmailConfigurationPresenter < SimpleDelegator
  include System::UrlHelpers.system_url_helpers

  def index_table_data
    {
      id: id,
      email: email,
      userName: user_name,
      updatedAt: updated_at.to_s(:long),
      links: links
    }
  end

  def links
    {
      edit: edit_provider_admin_account_email_configuration_path(self)
    }
  end

  def form_data
    {
      email: email,
      userName: user_name,
      password: password
    }
  end

  def edit_form_data
    form_data.merge({ id: id })
  end
end
