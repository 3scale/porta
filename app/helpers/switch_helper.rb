module SwitchHelper
  # Renders content that can be switched between enabled and disabled state using javascript.
  #
  # The helper yields a context object with two methods: enabled and disabled. The +enabled+
  # block should contain the content rendered in the "enabled" state, the +disabled+ the
  # content in "disabled" state. Both contents will be rendered, but the disabled one will be
  # hidden using "display:none" style rule.
  #
  # The argument should be a boolean value indicating the initial state.
  #
  #
  # == Example
  #
  #   <%= switch(launch_enabled?) do |context| %>
  #     <%= context.enabled %>
  #       <a href="/launch">Launch!</a>
  #     <% end %>
  #     <%= context.disabled %>
  #       <p>Insufficient fuel!</p>
  #     <% end %>
  #   <% end %>
  #
  def switch(enabled = true)
    yield(Context.new(self, enabled))
    ""
  end

  class Context
    def initialize(template, enabled)
      @template = template
      @enabled  = enabled
    end

    def enabled(&block)
      branch(:enabled, enabled?, &block)
    end

    def disabled(&block)
      branch(:disabled, !enabled?, &block)
    end

    private

    def branch(type, visible, &block)
      content_tag('div', capture(&block),
                       :class => "#{type}_block",
                       :style => visible ? nil : 'display:none')
    end

    attr_reader :template

    delegate :capture, :content_tag, :to => :template

    def enabled?
      @enabled
    end
  end
end
