# frozen_string_literal: true

# Extends Capybara methods to include Patternfly and other custom elements, such as CodeMirror.

# rubocop:disable Naming/PredicateName
module CapybaraExtensions
  # Capybara::Node::Actions#fill_in
  def fill_in(field, with:, **options)
    if page.has_css?('.pf-c-form__label', text: field, wait: 0)
      control = find('.pf-c-form__group-label', text: field).sibling('.pf-c-form__group-control')

      if control.has_css?('.CodeMirror', wait: 0)
        fill_in_api_docs_service_body(with)
      else
        control.find('input, textarea').set with
      end
    else
      ActiveSupport::Deprecation.warn "[cucumber] field not implemented with Patternfly: #{field}"
      super
    end
  end

  # Capybara::Node::Actions#select
  def select(value = nil, from: nil, **options)
    if has_css?('.pf-c-form__group', text: from, wait: 0)
      within('.pf-c-form__group', text: from) do
        if has_css?('select.pf-c-form-control', wait: 0)
          super
        else
          find('.pf-c-select').click
          find('.pf-c-select__menu button', text: value).click
        end
      end
    else
      ActiveSupport::Deprecation.warn "[cucumber] Select not implemented with Patternfly: #{from}"
      super
    end
  end

  # Capybara::Node::Finders#find_field
  def find_field(locator, **options)
    if has_css?('.pf-c-form__label', text: locator, wait: 0)
      find('.pf-c-form__group', text: locator).find('input, textarea, select, .CodeMirror', **options)
    else
      super
    end
  end

  # Capybara::Node::Matchers#has_select?
  def has_select?(locator = nil, **options, &optional_filter_block)
    if (form_group = find_all('.pf-c-form__group', text: locator, wait: 0).first)
      pf4_match = form_group.has_css?('.pf-c-select', wait: 0)
    end

    pf4_match || super
  end

  # Capybara::Node::Matchers#has_field?
  def has_field?(locator = nil, **options, &optional_filter_block)
    form_group = find_all('.pf-c-form__group', text: locator, wait: 0).first

    if form_group&.has_css?('.CodeMirror', wait: 0)
      # If the field is enhanced by CodeMirror, the textarea will be hidden.
      options[:visible] = :hidden
    end

    # Matches patternfly_check_boxes_input
    return true if form_group&.has_css?('.pf-c-form__group-control .pf-c-check', wait: 0)

    super
  end
end
# rubocop:enable Naming/PredicateName

World(CapybaraExtensions)
