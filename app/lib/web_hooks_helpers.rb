module WebHooksHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    # the model fires webhooks on typical: create, update and destroy events
    def fires_human_web_hooks_on_events
      after_commit :push_web_hooks_later, :unless => :destroyed?
      after_commit :push_destroy_web_hook, :on => :destroy
    end
  end

  # these 2 methods are not useless, they are a way to make it possible to
  # tweak the web_hooks push logic, e.g. see cinstance
  def push_web_hooks_later(options = {})
    web_hook_human_event(options)
  end

  def push_destroy_web_hook
    web_hook_human_event(:event => 'deleted')
  end

  def web_hook_event!(options)
    WebHook::Event.enqueue(provider_account, self, options)
  end

  def web_hook_human_event(options = {}, &block)
    if User.current && @webhook_event != false
      options = options.merge(:user => User.current)
      options[:event] = @webhook_event if @webhook_event

      web_hook_event!(options)
    end
  ensure
    @webhook_event = nil
  end
end
