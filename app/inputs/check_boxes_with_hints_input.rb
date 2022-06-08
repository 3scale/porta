# frozen_string_literal: true

class CheckBoxesWithHintsInput < Formtastic::Inputs::CheckBoxesInput
  def choice_html(choice)
    super(choice) <<
    template.content_tag(:p, hint(choice), class: 'inline-hints')
  end

  private

  def hint(choice)
    options[:member_hint].call(choice.is_a?(Array) ? choice.last : choice)
  end
end
