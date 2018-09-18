class CMS::Builtin::LegalTerm < CMS::Builtin::Partial

  SIGNUP_SYSTEM_NAME = 'signup_licence'
  SUBSCRIPTION_SYSTEM_NAME = 'service_subscription_licence'
  NEW_APPLICATION_SYSTEM_NAME = 'new_application_licence'

  attr_accessible :published

  validates :published, presence: true
  validates :title, uniqueness: { :scope => [:provider_id] }

  def title
    I18n.t("builtin_legal_terms.#{system_name}.title")
  end

  def description
    I18n.t("builtin_legal_terms.#{system_name}.description")
  end

  def self.system_name_whitelist
    [ SIGNUP_SYSTEM_NAME, SUBSCRIPTION_SYSTEM_NAME, NEW_APPLICATION_SYSTEM_NAME ]
  end

  module ProviderAssociationExtension
      def find_or_build_by_system_name(system_name, attributes)
        raise ActiveRecord::RecordNotFound unless system_name_whitelist.include?(system_name)

        find_by_system_name(system_name) || new(attributes) do |lt|
          lt.system_name = system_name
        end
      end
  end

  def save(*)
    self.published = self.draft
    super
  end

  def content_type
    "text/html"
  end

end
