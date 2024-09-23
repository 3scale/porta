# frozen_string_literal: true

class PatternflyCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput
  delegate :tag, to: :template

  def to_html
    tag.div(class: 'pf-c-form__group') do
      label + control
    end
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
      collection.map { |item| choice_html(item) }.reduce(&:concat) <<
        helper_text_invalid
    end
  end

  def choice_html(choice)
    tag.div(class: 'pf-c-check') do
      checkbox_input(choice) + choice_label(choice)
    end
  end

  def checkbox_input(choice)
    value = choice_value(choice)
    template.check_box_tag(
      input_name,
      value,
      checked?(value),
      extra_html_options(choice).merge(id: choice_input_dom_id(choice),
                                       class: 'pf-c-check__input',
                                       required: false)
    )
  end

  def choice_label(choice)
    label_text = choice[0]
    tag.label(label_text, class: 'pf-c-check__label',
                          for: choice_input_dom_id(choice))
  end

  def helper_text_invalid
    return if errors.empty?

    template.render partial: 'shared/pf_error_helper_text', locals: { error: errors.first }
  end
end
