# frozen_string_literal: true

Then "{string} {should} be visible" do |text, visible|
  node_with_text(text, visible).visible?.should be visible
end

Then "{string} within {string} {should} be visible" do |text, selector, visible|
  with_scope(selector) do
    node_with_text(text, visible).visible?.should be visible
  end
end

def node_with_text(text, visible)
  find(:xpath, "//*[text() = #{text.inspect}]", visible: visible ? :visible : :hidden)
end
