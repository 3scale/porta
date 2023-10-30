# frozen_string_literal: true

class PatternflyCheckboxInput < Formtastic::Inputs::BooleanInput
  delegate :tag, to: :template

  def to_html
    tag.div(class: 'pf-c-form__group') do
      tag.div(class: 'pf-c-form__group-control') do
        tag.div(class: 'pf-c-check') do
          hidden_field_html + input + label + description
        end
      end
    end
  end

  private

  def input_html_options
    super.merge(class: 'pf-c-check__input')
  end

  def input
    check_box_html
  end

  def label
    tag.label(label_text, class: 'pf-c-check__label', for: input_html_options[:id])
  end

  def description
    tag.span(hint_text, class: 'pf-c-check__description')
  end
end
