# frozen_string_literal: true

Then "{string} within {string} {should} be visible" do |text, selector, visible|
  with_scope(selector) do
    node_with_text(text, :visible).visible?.should be visible
  end
end

def node_with_text(text, visible)
  find(:xpath, "//*[text() = #{text.inspect}]", visible: visible)
end
