# TODO: This should be likewise splited to provider/buyer (developer_portal)
#
module Messenger
  class Base

    include MessageLiquidizer
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::UrlHelper

    def initialize(method_name=nil, *args)
      @_message = Message.new
      @_template_name = method_name
      setup(*args)
      send(method_name,*args) if method_name
      Rails.logger.info("[Messenger] rendering #{full_template_name}")
    end

    def setup(*args)
      # override with setup code
    end

    def full_template_name
      self.class.name.underscore << "_" << @_template_name.to_s.underscore
    end

    def current_liquid_templates
      source = template_source
      source.email_templates if source.respond_to?(:email_templates)
    end

    def developer_portal_routes
      @developer_portal_routes ||= DeveloperPortalRoutes.new
    end

    def app_routes
      @app_routes ||= AppRoutes.new
    end

    def deliver
      @_message.deliver!
    end

    alias_method :deliver_now, :deliver

    def message(options={})
      m = @_message

      m.attributes = options
      m.body = find_and_parse_body(options[:body], :message => m)

      Rails.logger.info("[Messenger] delivering to #{m.to.inspect}")
      Rails.logger.debug { "[Messenger] using template source #{template_source.inspect}" }

      m.save!
      m
    end

    # HACK: HACK HACK for url_for
    def controller
      nil
    end

    # this method determines what to use as template source
    # - tries to find provider as sender or single recipient
    def template_source
      sender = @_message.sender

      # if provider sends message to buyer, source is provider
      # try - rpovider is sender, reciever is master
      # test - sender as provider, -
      if sender.provider?
        if @_message.to == [ Account.master ]
          Account.master
        else
          sender
        end

      # but when sender is buyer and sends message to provider
      # provider should be able to override that template
      elsif sender.buyer?
        recipients = @_message.to

        # so we verify there is only one recipient
        if recipients.size == 1
          receiver = recipients.first

          # and if that recipient is provider
          # then is safe to use him as template source
          if receiver.provider?
            receiver
          else
            Rails.logger.warn "~~~ Messenger::Base - only recipient is not provider, cannot find template source"
            sender
          end
        else
          Rails.logger.warn "~~~ Messenger::Base - multiple recipients detected, cannot determine provider template"
          sender
        end
      else
        Rails.logger.warn "~~~ Messenger::Base - something strange happened, couldn't find templates for message: #{@_message.inspect}"
        sender
      end
    end

    private


    class << self

      def method_missing(method, *args)
        if respond_to?(method)
          new(method, *args)
        else
          super
        end
      end

      def respond_to?(method)
        # in ruby 1.9 the elements of that array are symbols, not strings
        instance_methods.any?{|m| m.to_s == method.to_s} or super
      end
    end
  end


  class DeveloperPortalRoutes
    include DeveloperPortal::Engine.routes.url_helpers

    private

    def default_url_options
      Rails.configuration.action_mailer.default_url_options || {}
    end

  end

  class AppRoutes
    include Rails.application.routes.url_helpers

    private

    def default_url_options
      Rails.configuration.action_mailer.default_url_options || {}
    end
  end
end
