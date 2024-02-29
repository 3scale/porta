# frozen_string_literal: true

# rubocop:disable Naming/PredicateName
module CapybaraExtensions
  # Overrides Capybara::Node::Actions#fill_in
  def fill_in(field, with:, **options)
    if page.has_css?('.pf-c-form__label', text: field, wait: 0)
      input = find('.pf-c-form__group-label', text: field).sibling('.pf-c-form__group-control')
                                                          .find('input, textarea')
      input.set with
    else
      ActiveSupport::Deprecation.warn "[cucumber] field not implemented with Patternfly: #{field}"
      super
    end
  end

  # Overrides Capybara::Node::Actions#select
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

  # Overrides Capybara::Node::Finders#find_field
  def find_field(locator, **options)
    if has_css?('.pf-c-form__label', text: locator, wait: 0)
      find('.pf-c-form__group', text: locator).find('input, textarea, select', options)
    else
      super
    end
  end

  # Overrides Capybara::Node::Matchers#find_field
  def has_select?(locator = nil, **options, &optional_filter_block)
    if has_css?('.pf-c-form .pf-c-select', wait: 0)
      find('.pf-c-form__group', text: locator).has_css?('.pf-c-select', wait: 0)
    else
      super
    end
  end
end

World(CapybaraExtensions)

# rubocop:enable Naming/PredicateName
