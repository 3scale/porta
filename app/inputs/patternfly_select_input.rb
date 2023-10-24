# frozen_string_literal: true

class PatternflySelectInput < Formtastic::Inputs::SelectInput
  delegate :tag, to: :template

  def to_html
    tag.div(class: 'pf-c-form__group') do
      label + control + helper_text
    end
  end

  private

  def input_html_options
    super.merge(class: 'pf-c-form-control')
  end

  def label_html_options
    super.merge(class: 'pf-c-form__label')
  end

  def label
    tag.div(class: 'pf-c-form__group-label') do
      tag.label(class: 'pf-c-form__label', for: input_html_options[:id]) do
        tag.span(label_text, class: 'pf-c-form__label-text')
      end
    end
  end

  def control
    tag.div(class: 'pf-c-form__group-control') do
      select_html
    end
  end

  def helper_text
    tag.div(hint_text, class: 'pf-c-form__helper-text') if hint?
  end
end
