module HelpBubblesHelper
  # TODO: This thing should be cleaned up a little and pluginized.

  # Render help bubble.
  #
  # == Arguments
  #
  # +id+:: unique id of this bubble.
  # +text+:: content of a bubble (or block is evaluated)
  #
  # == Example
  #
  #  <% help_bubble("stuff") do %>
  #    <h3>Some title</h3>
  #    <p>Some content...</p>
  #  <% end %>
  #
  # Note that as with any helper that takes a block, you have to use it inside
  # <% ... %> tags, not <%= ... %> tags.
  #
  def help_bubble(id = nil, text = nil, &block)
    id ||= "help_bubble_#{SecureRandom.hex(4)}"
    text ||= capture(&block)


    trigger = image_tag('provider/icons/questionPassive.png', :class => 'helpButton', :id => id)

    bubble = content_tag(:div,
      content_tag(:div, text, :class => 'inlineHelperContent'),
        :class => 'inlineHelper',
        :id => "help_layer_#{id}",
        :style => 'display: none')

    widget = trigger + bubble
  end
end
