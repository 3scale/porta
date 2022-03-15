# frozen_string_literal: true

module Liquid
  module Filters
    module RailsHelpers
      extend ActionView::Helpers::TagHelper
      extend ActionView::Helpers::UrlHelper
      extend ActionView::Helpers::AssetTagHelper

      include Liquid::Filters::Base

      THREESCALE_STYLESHEETS = %w[legacy/stats plans_widget.css active-docs/application.css stats.css].freeze
      THREESCALE_JAVASCRIPTS = %w[plans_widget.js plans_widget_v2.js active-docs/application.js stats.js].freeze
      THREESCALE_WEBPACK_PACKS = %w[stats.js active_docs.js load_stripe.js validateSignup.js].freeze
      THREESCALE_IMAGES      = %w[spinner.gif tick.png cross.png].freeze
      ACTIVE_DOCS_JS = %w[active-docs/application.js active_docs.js].freeze

      desc "Group collection by some key."
      example "Group applications by service.", %(
        {% assign grouped = applications | group_by: 'service' %}
        {% for group in grouped %}
          Service: {{ group[0 }}
          {% for app in group[1] %}
            Application: {{ app.name }}
          {% endfor %}
        {% endfor %}
      )
      def group_by(collection, key)
        collection.group_by{|element| element.invoke_drop(key) } if collection.present?
      end

      desc "True if any string in the collection equals to the parameter."
      example "Are there any pending apps of the current account?", %(
         {% assign has_pending_apps = current_account.applications | map: 'state' | any: 'live' %}
      )
      def any(collection, string)
        Array(collection).any? { |element| element.to_s == string.to_s }
      end

      desc 'Stylesheet link'
      def stylesheet_link_tag(name)
        if THREESCALE_STYLESHEETS.include?(name)
          view.stylesheet_link_tag(name)
        else
          RailsHelpers.tag(:link, rel:"stylesheet", type: Mime[:css], media: "screen", href: get_path(name))
        end
      end

      desc "Javascript includes tag."
      def javascript_include_tag(name, options = {})
        js = RailsHelpers.replace_googleapis(name)
        case
        when THREESCALE_WEBPACK_PACKS.include?(name) # TODO: This is an intermediate step in order to tackle webpack assets in dev portal. A final solution might be needed easing the update of templates/assets.
          active_docs_proxy(name) + view.javascript_pack_tag(name, options)
        when js != name || THREESCALE_JAVASCRIPTS.include?(js)
          active_docs_proxy(js) + view.javascript_include_tag(js)
        else
          RailsHelpers.content_tag(:script, '', src: get_path(name))
        end
      end

      desc "Outputs an <img> tag using the parameters as its `src` attribute."
      example %(
        {{ 'http://example.com/cool.gif' | image_tag }}
        # => <img src="http://example.com/cool.gif" >
      )
      def image_tag(name)
        if THREESCALE_IMAGES.include?(name)
          view.image_tag(name)
        else
          RailsHelpers.content_tag(:img, '', src: get_path(name) )
        end
      end

      # TODO: consider allowing more parameters
      desc "Converts email address to a 'mailto' link."
      example %(
        {{ 'me@there.is' | mail_to }}
        # => <a href="mailto:me@there.is">me@there.is</a>
      )
      def mail_to(mail)
        RailsHelpers.mail_to(mail.to_s)
      end

      desc "Marks content as HTML safe so that it is not escaped."
      def html_safe(output)
        if output.respond_to?(:html_safe)
          output.html_safe
        else
          output
        end
      end

      desc "Converts word to plural form."
      def pluralize(text)
        text.pluralize
      end

      desc """
        Generates a button to delete a resource present on the URL.
        First parameter is a URL, second is a title. You can also add more
        HTML tag attributes as a third parameter.

        To add a confirmation dialog, add a confirm attribute with a
        confirmation text
      """
      example %(
        {{ 'Delete Message' | delete_button: message.url, class: 'my-button',
          confirm: 'are you sure?' }}
      )
      def delete_button(title, url, html_options = {})
        button title, url, :delete, RailsHelpers.sanitize_options(html_options)
      end

      desc """
        Generates a button to delete a resource present on the URL using AJAX.
        First parameter is a URL, second is a title.

        To add a confirmation dialog, add a confirm attribute with a
        confirmation text.
      """
      example %(
        {{ 'Delete Message' | delete_button_ajax: message.url, confirm: 'are you sure?' }}
      )
      def delete_button_ajax(title, url, html_options = {})
        # legacy compatibility
        html_options['class'] ||= 'action delete remote'
        button title, url, :delete, RailsHelpers.sanitize_options(html_options).merge(remote: true)
      end

      desc """
        Generates a button to 'update' (HTTP PUT request) a resource present on the URL.
        First parameter is a URL, second is a title. You can also add more
        HTML tag attributes as a third parameter.

        To change the text of the submit button on submit, add a disable_with attribute with a
        the new button text.
      """
      example %(
        {{ 'Resend' | update_button: message.url, class: 'my-button', disable_with: 'Resending…' }}
      )
      def update_button(title, url, html_options = {})
        # legacy compatibility
        html_options['class'] ||= 'update'
        button title, url, :put, RailsHelpers.sanitize_options(html_options)
      end

      desc """
        Generates a button to 'update' (HTTP PUT request) a resource present on
        the URL using AJAX. First parameter is a URL, second is a title. You can
        also add more HTML tag attributes as a third parameter.

        To change the button text on submit, add a disable_with attribute with a
        the new button text.
      """
      example %(
        {{ 'Resend' | update_button: message.url, class: 'my-button', disable_with: 'Resending…' }}
      )
      def update_button_ajax(title, url, html_options = {})
        # legacy compatibility
        html_options['class'] ||= 'update remote'
        button title, url, :put, RailsHelpers.sanitize_options(html_options).merge(remote: true)
      end

      desc """
        Generates a button to create a resource present on the URL.
        First parameter is a URL, second is a title. You can
        also add more HTML tag attributes as a third parameter.

        To change the button text on submit, add a disable_with attribute with a
        the new button text.
      """
      example %(
        {{ 'Create Message' | create_button: message.url, disable_with: 'Creating message…' }}
      )
      def create_button(title, url, html_options = {})
        html_options['class'] ||= 'create_key'
        button title, url, :post, RailsHelpers.sanitize_options(html_options)
      end

      desc """
        Generates a button to create a resource present on the URL using AJAX.
        First parameter is a URL, second is a title. You can
        also add more HTML tag attributes as a third parameter.

        To change the button text on submit, add a disable_with attribute with a
        the new button text.
      """
      example %(
        {{ 'Create Message' | create_button: message.url, disable_with: 'Creating message…' }}
      )
      def create_button_ajax(title, url, html_options = {})
        # legacy compatibility
        html_options['class'] ||= 'create'
        button title, url, :post, RailsHelpers.sanitize_options(html_options).merge(remote: true)
      end

      def regenerate_oauth_secret_button(title, url)
        update_button_ajax title, url, { 'class' => 'btn btn-danger', 'disable_with' => 'Generating...' }
      end

      desc "Create link from given text"
      example %(
        {{ "See your App keys" | link_to:'/my-app-keys' }}
      )
      def link_to(text, path, html_options = {})
        RailsHelpers.link_to(text, path.to_s, RailsHelpers.sanitize_options(html_options))
      end

      def dom_id(instance)
        ActionView::RecordIdentifier.dom_id(to_model(instance))
      end

      private

      def to_model(drop)
        drop.instance_variable_get :@model
      end

      DATA_ATTRIBUTES = %i[confirm disable_with].freeze

      def self.sanitize_options(options)
        return {} unless options.present?
        sanitized = options.stringify_keys

        data_attributes = sanitized.with_indifferent_access.slice(*DATA_ATTRIBUTES)

        sanitized.each do |key, value|
          sanitized[key] = value.to_s
        end

        sanitized.except(*data_attributes.keys).merge(data_attributes.present? ? {data: data_attributes} : {})
      end

      # This replaces remote call to googleapis with local asset pipeline
      # we don't want to hit google in every javascript test of buyer side
      def self.replace_googleapis(url)
        return url unless Rails.env.test?

        if url =~ %r{//ajax.googleapis.com/ajax/libs/jquery/(.+?)/jquery.min.js}
          "vendor/jquery-#{$1}.min.js"
        else
          url
        end
      end

      def get_attachment(path)
        controller = @context.registers[:controller] or return
        site_account = controller.send(:site_account) or return
        site_account.files.find_by_path(path.to_s)
      end

      def get_path(name)
        if file = get_attachment(name)
          file.url
        else
          name.to_s
        end
      end

      def view
        @context.registers.fetch(:view) { controller.view_context }
      end

      def controller
        @context.registers.fetch(:controller)
      end

      def button(title, url, method, options={})
        view.button_to title.to_s, url.to_s, {method: method}.merge(options)
      end

      ENABLE_API_DOCS_PROXY = "window.enableApiDocsProxy = #{Rails.configuration.three_scale.active_docs_proxy_disabled.blank?};\n"

      def active_docs_proxy(name)
        if name.in?(ACTIVE_DOCS_JS)
          view.javascript_tag ENABLE_API_DOCS_PROXY
        else
          "".html_safe
        end
      end
    end
  end
end
