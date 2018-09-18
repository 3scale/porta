module Liquid
  module TemplateSupport
    extend ActiveSupport::Concern

    module ClassMethods
      # Usage:
      #   MyController < FrontendController
      #    liquify prefix: 'applications'
      #
      #    def show
      #     # will try to render liquid template
      #     # with system name 'applications/show'
      #    end
      #  end
      def liquify(options = {})
        layout :find_builtin_static_page_layout

        before_action(options) do
          add_liquid_view_paths(options)
        end

        after_action(options) do
          liquid_database_resolver.clear_cache
        end
      end
    end

    protected

    def add_liquid_view_paths(options={})
      # liquid from the database
      prepend_view_path(liquid_database_resolver)

      # ERBs
      prepend_view_path(rails_without_liquid_resolver)

      # liquid from filesystem
      append_view_path(liquid_filesystem_resolver)

      append_view_path(liquid_filesystem_resolver_no_prefix)

      # TODO: remove this hack and move templates to right place
      if prefix = options[:prefix]
        define_singleton_method(:_prefixes) do
          super().unshift(prefix)
        end
      end

      view_renderer.extend(LayoutSupport)
    end

    class LiquidTemplateRenderer < ::ActionView::TemplateRenderer
      def determine_template(options)
        super.tap do |template|
          unless template.respond_to?(:layout)
            Rails.logger.info "#{template.inspect} is not Liquid template and can't override layout"
            next
          end

          if overridden = template.layout
            original = options.delete(:layout)
            options[:layout] = overridden
            Rails.logger.info "Rendering #{template.inspect} with #{overridden} instead of #{original}"
          end
        end
      end
    end

    module LayoutSupport
      # RAILS: this overrides rails method, beware when upgrading
      def render_template(context, options)
        LiquidTemplateRenderer.new(@lookup_context).render(context, options)
      end
    end

    def assigns_for_liquify
      original = {}

      @_assigned_drops ||= {}
      @_template_assigns ||= {}

      report_and_supress_exceptions do
        diff = original.keys - @_assigned_drops.keys
        overriden = @_template_assigns.keys & @_assigned_drops.keys

        if diff.present?
          Rails.logger.info "[LiquidTemplateSupport] Automatic assign would assign also #{diff.to_sentence}. Please assign them manually."
        end

        if overriden.present?
          raise "Assigning #{overriden.to_sentence} would override variables in template."
        end
      end

      @_assigned_drops
    end

    public :assigns_for_liquify

    private

    def rails_without_liquid_resolver
      Liquid::Template::WithoutLiquidResolver.new
    end

    def liquid_database_resolver
      Liquid::Template::Resolver.instance(site_account).tap do |resolver|
        # assign controller to resolver, so it can get liquid variables
        resolver.cms = cms
      end
    end

    def liquid_filesystem_resolver
      Liquid::Template::FallbackResolver.new
    end

    def liquid_filesystem_resolver_no_prefix
      Liquid::Template::FallbackResolverNoPrefix.new
    end



    def current_liquid_templates
      site_account.templates
    end

    def prepare_liquid_template(template)
      cms_toolbar.liquid(template)

      template.registers[:controller] ||= self
      template.registers[:request] ||= request
      template.registers[:current_account] ||= current_account
      template.registers[:site_account] ||= site_account

      template.registers[:draft] ||= cms.render_draft_content?
      template.registers[:escape_html] ||= cms.escape_html?

      template.registers[:content_for] ||= cms.content_for_store

      template.registers[:file_system] ||= CMS::DatabaseFileSystem.new(site_account, lookup_context)

      template_assigns template,
        :site    => Liquid::Drops::Site.new(site_account),
        :request => Liquid::Drops::Request.new(request),
        :urls    => Liquid::Drops::Urls.new(site_account, request),

        :site_account => Liquid::Drops::Provider.new(site_account),
        :provider     => Liquid::Drops::Provider.new(site_account),
        :forum        => Liquid::Drops::Forum.new(site_account),
        :today        => Liquid::Drops::Today.new,
        :i18n         => Liquid::Drops::I18n.new,
        content_of:      Liquid::Drops::ContentOf.new,
        flash:           Liquid::Drops::Flash.new(request.flash.to_a),
        :model => Liquid::Drops::NewSignup.new(site_account, request.params, current_account),

        # underscore prefix means it is "private" api and can be changed without further notice
        :_menu => Liquid::Drops::Menu.new(active_menus),
        :menu => Liquid::Drops::Menu.new(active_menus)

      if logged_in?
        template_assigns template,
          :current_account => Liquid::Drops::Account.new(current_account),
          :current_user => Liquid::Drops::CurrentUser.new(current_user)
      end
    end

    # WARNING! all keys to assigns have to be strings, not symbols!
    # Otherwise the Liquid render method won't find them when
    # evaluating the template.
    #
    def template_assigns(template, assigns)
      @_template_assigns = template.assigns
      @_template_assigns.merge! assigns.stringify_keys
    end

    def self.fetch_drop(name)
      # TODO: in Ruby 1.9 use get_const(name, false) so it really looks only in drop module scope
      [Liquid::Drops, name.camelize].join("::").constantize
    end
  end
end
