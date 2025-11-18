# frozen_string_literal: true

class PatternflyCheckboxInput < Formtastic::Inputs::BooleanInput
  delegate :tag, to: :template

  def self.block_compatible?
    true
  end

  def to_html
    tag.div(class: 'pf-c-form__group') do
      tag.div(class: 'pf-c-form__group-control') do
        tag.div(class: 'pf-c-check') do
          content = hidden_field_html + input + label + description
          content += template.capture(&options[:block]) if options[:block]
          content
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
    disabled = input_html_options[:disabled]
    tag.label(label_text, class: "pf-c-check__label#{disabled ? ' pf-m-disabled' : ''}",
                          for: input_html_options[:id])
  end

  def description
    tag.span(hint_text, class: 'pf-c-check__description')
  end
end
