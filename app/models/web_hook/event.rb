require 'securerandom'

class WebHook
  class Event
    class Error < ::StandardError; end
    class MissingResourceError < Error; end

    # This object represents one webhook event
    # it checks if the webhook should be fired or not
    # and encapsulates all the logic of getting right event, logging, etc.

    attr_reader :id, :provider, :webhook, :resource, :options

    def self.enqueue(provider, resource, options = {})
      job = new(provider, resource, options)
      job.valid? ? job.enqueue : job.ignore
    end

    def initialize(provider, resource, options = {})
      @id       = SecureRandom.uuid
      @resource = resource or raise MissingResourceError

      if (@provider = provider)
        @webhook  = provider.web_hook
      end

      @options  = options.symbolize_keys

      logger.info "New WebHook::Event(#{id}) #{event} for #{model}(##{resource.id})"
    end

    def event
      @event ||= @options[:event] || guess_event
    end

    def model
      resource.class.model_name
    end

    delegate :logger, to: :Rails

    def has_transactional_callbacks?
      true
    end

    def enqueue
      logger.info "Will enqueue WebHook::Event(#{id}) #{event} after commit for #{model}##{resource.id}"
      # Only modify the singleton_class of the instance and not the class
      # This way we are not modifying the _commit_callbacks queue of the resource.class but only the resource Eigenclass
      resource.singleton_class.after_commit &method(:committed!)
    end

    def committed!(*)
      enqueue_now
    end

    def rolledback!(*)
      logger.info "Rolledback WebHook::Event(#{id}) #{event} for #{model}##{resource.id}"
    end

    def enqueue_now
      logger.info "Pushed WebHook::Event(#{id}) #{event} for #{model}##{resource.id}"
      WebHookWorker.perform_async(id, provider_id: provider.id, url: url, xml: to_xml, content_type: content_type)
    end

    def ignore
      logger.info "Ignoring WebHook::Event(#{id}) #{event} for #{model}(#{resource.id})"
      false
    end

    # this could be activemodel validation
    def valid?
       enabled? && push_event?  && push_user? && provider.web_hooks_allowed?
    end

    # use i18n to figure this out
    def resource_type
      case model
      when "Cinstance"
        'application'
      else
        model.singular
      end
    end

    def user
      @user ||= options[:user]
    end

    def url
      @url ||= WebHook.sanitized_url || webhook.url
    end

    def content_type
      if webhook.push_application_content_type
        'application/xml'
      end
    end

    def to_xml(options = {})
      builder = options[:builder] || ::ThreeScale::XML::Builder.new
      builder.event do |xml|
        xml.action event
        xml.type_ resource_type
        xml.object do |xml|
          resource.to_xml(:builder => builder)
        end
      end
      builder.to_xml
    end

    def enabled?
      provider && webhook && webhook.enabled?(resource_type, event)
    end

    def push_user?
      return true unless user

      # return if providers accounts do not match
      return unless resource.provider_account == self.provider

      if user.account.buyer?
        # check if user is buyer of provider of this webhook
        user.account.provider_account == self.provider
      elsif user.account.provider?
        webhook.provider_actions
      end
    end

    def push_event?
      event.present?
    end

    protected

    delegate :connection, to: 'ActiveRecord::Base'

    def guess_event
      case
      when @resource.destroyed?
        'deleted'
      when @resource.created_at.present? && @resource.created_at == @resource.updated_at
        'created'
      when @resource.updated_at.present?
        'updated'
      end
    end
  end
end
