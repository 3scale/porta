# frozen_string_literal: true

class Provider::Admin::CMS::VersionsShowPresenter
  include ::Draper::ViewHelpers

  def initialize(page:, version:)
    @page = page
    @version = version
  end

  attr_reader :page, :version

  def revert_button
    h.pf_link_to t('.revert.title'),
                 h.revert_provider_admin_cms_template_version_path(page, version),
                 variant: :danger,
                 :'data-method' => :post,
                 :'data-confirm' => t('.revert.confirm', name: page.name, version: l(version.created_at), state: version.state)
  end

  private

  # :reek:UncommunicativeMethodName
  def t(str, **opts)
    I18n.t("provider.admin.cms.versions#{str}", **opts)
  end
end
