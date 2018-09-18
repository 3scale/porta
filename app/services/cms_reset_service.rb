class CMSResetService

  def call(provider)
    Account.transaction do
      provider.files.destroy_all
      provider.templates.delete_all
      provider.sections.delete_all
      provider.provided_groups.destroy_all
      provider.email_templates.destroy_all

      SimpleLayout.new(provider).import!
    end
  end
end
