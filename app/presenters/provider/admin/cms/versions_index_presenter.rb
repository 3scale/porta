# frozen_string_literal: true

class Provider::Admin::CMS::VersionsIndexPresenter
  include ::Draper::ViewHelpers

  def initialize(page:, params: {})
    @page = page
    @pagination_params = {
      page: params.fetch(:page, 1),
      per_page: params.fetch(:per_page, 20)
    }
  end

  attr_reader :page

  def versions
    @versions ||= page.versions.order(created_at: :desc, id: :asc).paginate(@pagination_params)
  end

  def toolbar_props
    {
      totalEntries: versions.total_entries
    }
  end

  def revert_button_to(version)
    h.link_to t('.revert.title'),
              h.revert_provider_admin_cms_template_version_path(page, version),
              class: 'action revert',
              :'data-method' => :post,
              :'data-confirm' => t('.revert.confirm', name: page.name, version: l(version.created_at), state: version.state)
  end

  def back_button
    h.pf_link_to 'Back', h.polymorphic_path([:edit, :provider, :admin, @page]), variant: :primary
  end

  # :reek:TooManyStatements
  def changes_of(version, index) # rubocop:disable Metrics/AbcSize
    next_version = versions[index + 1]

    stats = version.diff(next_version).stats
    changes = stats.map { |key, count| h.pluralize(count, key.to_s) }.presence
    title = changes ? changes.to_sentence : "no changes"

    h.content_tag(:span, class: 'diff', title:) do
      h.content_tag(:span, "+#{stats[:addition]}", class: 'plus') + h.content_tag(:span, "-#{stats[:deletion]}", class: 'minus')
    end
  end

  private

  # :reek:UncommunicativeMethodName
  def t(str, **opts)
    I18n.t("provider.admin.cms.versions#{str}", **opts)
  end
end
