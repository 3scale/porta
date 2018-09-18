class CMS::Builtin < CMS::BasePage
  self.search_origin = 'builtin'

  ##
  # WARNING: CMS::Builtin::Layout and CMS::Builtin::Page classes are inside this file
  # because Rails autoloading has nasty race condition
  #
  # if you load Builtin class, it does not load subclasses
  # so has_many :builtins assoctiation won't work as it won't search for subclasses
  #

  ORIGINAL_PATHS = {
    'errors/not_found'  =>  full_path('errors/not_found.html.liquid'),
    'errors/forbidden'  =>  full_path('errors/forbidden.html.liquid'),
    'errors/internal_server_error' =>  full_path('errors/internal_server_error.html.liquid'),
    'dashboards/show'       => full_path('dashboards/show.html.liquid'),
    'applications/new'      => full_path('applications/new.html.liquid'),
    'applications/choose_service' => full_path('applications/choose_service.html.liquid'),
    'applications/edit'     => full_path('applications/edit.html.liquid'),
    'applications/index'    => full_path('applications/index.html.liquid'),
    'applications/show'     => full_path('applications/show.html.liquid'),
    'applications/alerts/index' => full_path('applications/alerts/index.html.liquid'),
    'invoices/index'        => full_path('invoices/index.html.liquid'),
    'invoices/show'         => full_path('invoices/show.html.liquid'),
    'account/show'          => full_path('account/show.html.liquid'),
    'account/edit'          => full_path('account/edit.html.liquid'),
    'accounts/users/index'  => full_path('accounts/users/index.html.liquid'),
    'accounts/users/edit'   => full_path('accounts/users/edit.html.liquid'),
    'user/show'             => full_path('user/show.html.liquid'),
    'messages/outbox/index' => full_path('messages/outbox/index.html.liquid'),
    'messages/outbox/show'  => full_path('messages/outbox/show.html.liquid'),
    'messages/outbox/new'   => full_path('messages/outbox/new.html.liquid'),
    'messages/inbox/index'  => full_path('messages/inbox/index.html.liquid'),
    'messages/inbox/show'   => full_path('messages/inbox/show.html.liquid'),
    'messages/trash/index'  => full_path('messages/trash/index.html.liquid'),
    'messages/trash/show'   => full_path('messages/trash/show.html.liquid'),
    'signup/show'           => full_path('signup/show.html.liquid'),
    'signup/success'        => full_path('signup/success.html.liquid'),
    'login/new'             => full_path('login/new.html.liquid'),
    'password/new'          => full_path('password/new.html.liquid'),
    'password/show'         => full_path('password/show.html.liquid'),
    'services/new'          => full_path('services/new.html.liquid'),
    'services/index'        => full_path('services/index.html.liquid'),
    'invitations/index'     => full_path('invitations/index.html.liquid'),
    'invitations/new'       => full_path('invitations/new.html.liquid'),
    'accounts/payment_gateways/edit' => full_path('accounts/payment_gateways/edit.html.liquid'),
    'accounts/payment_gateways/show' => full_path('accounts/payment_gateways/show.html.liquid'),
    'account_plans/index'   => full_path('account_plans/index.html.liquid'),
    'accounts/plan_changes/index' => full_path('accounts/plan_changes/index.html.liquid'),
    'stats/index'           => full_path('stats/index.html.liquid'),
    'search/index'          => full_path('search/index.html.liquid'),
    'accounts/invitee_signups/show' => full_path('accounts/invitee_signups/show.html.liquid')
  }.freeze

  validates :system_name, presence: true

  attr_protected :liquid_enabled

  # TODO: this is a quick fix: we should set the liquid enabled attribute to true when creating builtin templates
  # in rails 4.2 use the attribute api
  def read_attribute(name)
    case name
    when 'liquid_enabled'.freeze
        true
    else
        super
    end
  end

  # TODO: create url for draft/published link
  #
  def search
    super.merge(string: "#{self.system_name}")
  end

  def name
    (parent_sections.map(&:title) << title).join(' - ')
  end

  def title
    scope = i18n_scope
    key = scope.pop
    I18n.t(key, :scope => scope, :default => key.humanize)
  end

  def description
    I18n.t(system_name, scope: %w|builtin_pages description|)
  end

  def reset!
    path = ORIGINAL_PATHS[system_name]
    raise "Tried to reset builtin with unknown system_name #{system_name}" unless path
    self.draft = path.read
    save!
  end

  private

  def destroy
    Rails.logger.warn("Deleting a builtin page #{self.id} of #{provider.name}")
    super
  end

  def i18n_scope
    self.class.to_s.underscore.split('/') + system_name.split('/')
  end

  # CMS::Builtin::StaticPage
  class StaticPage < CMS::Builtin
    validates_each :draft, :published do |record, attr, value|
      record.errors.add attr, :is_present if value.present?
    end

    def to_xml(options = {})
      xml = options[:builder] || Nokogiri::XML::Builder.new

      xml.builtin_page do |x|
        unless new_record?
          xml.id id
          xml.created_at created_at.xmlschema
          xml.updated_at updated_at.xmlschema
        end

        x.system_name system_name
        x.liquid_enabled liquid_enabled
        x.layout layout_name
      end

      xml.to_xml
    end
  end

  # CMS::Builtin::Page
  class Page < CMS::Builtin
    def to_xml(options = {})
      xml = options[:builder] || Nokogiri::XML::Builder.new

      xml.builtin_page do |x|
        unless new_record?
          xml.id id
          xml.created_at created_at.xmlschema
          xml.updated_at updated_at.xmlschema
        end

        # x.title title
        x.system_name system_name
        x.liquid_enabled liquid_enabled

        unless options[:short]
          x.draft draft
          x.published published
        end
      end

      xml.to_xml
    end

    def content_type
      'text/html'
    end

    protected

    def set_rails_view_path
      self.rails_view_path = system_name
    end

    module ProviderAssociationExtension
      def find_or_create!(system_name, title, section, layout_name = "main_layout")
        find_by_system_name(system_name) || create! do |p|
          provider = proxy_association.owner

          p.system_name = system_name
          p.title = title
          p.section = section
          p.draft = nil
          p.published = CMS::Builtin::Page::ORIGINAL_PATHS.fetch(system_name).read
          p.layout = provider.layouts.find_by_system_name(layout_name)
        end
      end
    end

  end

  # Beware, Builtin::Partial does not inherit from CMS::Builtin!
  # CMS::Builtin::Partial
  class Partial < CMS::Partial
    self.search_origin = 'builtin'

    private :destroy
    attr_readonly :system_name
    attr_protected :liquid_enabled

    # TODO: this is a quick fix: we should set the liquid enabled attribute to true when creating builtin templates
    def liquid_enabled?
      true
    end

    def self.filesystem_templates
      paths = ORIGINAL_PATHS

      if Rails.configuration.three_scale.active_docs_proxy_disabled
        paths = paths.merge(WITHOUT_APIDOCS_PROXY_PATHS)
      end

      paths
    end

    WITHOUT_APIDOCS_PROXY_PATHS = {
      'shared/swagger_ui' => full_path('shared/_swagger_ui_https.html.liquid'),
    }.freeze

    ORIGINAL_PATHS = {
      'stats/chart' => full_path('stats/_chart.html.liquid'),
      'applications/form' => full_path('applications/_form.html.liquid'),
      'messages/menu' => full_path('messages/_menu.html.liquid'),
      'shared/pagination' => full_path('shared/_pagination.html.liquid'),
      'shared/swagger_ui' => full_path('shared/_swagger_ui.html.liquid'),
      'signup/cas' => full_path('signup/_cas.html.liquid'),
      'login/sso' => full_path('login/_sso.html.liquid'),
      'field' => full_path('_field.html.liquid'),
      'submenu' => full_path('_submenu.html.liquid'),
      'menu_item' => full_path('_menu_item.html.liquid'),
      'users_menu' => full_path('_users_menu.html.liquid'),
    }.freeze

    private_constant :ORIGINAL_PATHS, :WITHOUT_APIDOCS_PROXY_PATHS

    def self.system_name_whitelist
      ORIGINAL_PATHS.keys
    end

    def system_name_rules
      if new_record?
        unless self.class.system_name_whitelist.include?(system_name)
          errors.add(:system_name, :not_reserved)
        end
      elsif system_name_changed? && attribute_was('system_name') != system_name
        errors.add(:system_name, :cannot_be_changed)
      end
    end

    # Sets draft to the original version that rests on the filesystem
    # and saves the partial.
    def reset!
      self.draft = find_original_file!.read
      save!
    end

    def title
      I18n.t("#{system_name}.title", scope: 'builtin_partials', default: system_name.humanize)
    end

    def to_xml(options = {})
      super options.merge(root: :builtin_partial)
    end

    protected

    def set_rails_view_path
      parts = system_name.split('/')
      parts.push("_#{parts.pop}")
      self.rails_view_path = parts.join('/')
    end

    private

    def find_original_file!
      Partial.filesystem_templates[system_name] or
        raise "Tried to reset builtin with unknown system_name #{system_name}"
    end

  end

end

CMS::BuiltinPage = CMS::Builtin::Page
