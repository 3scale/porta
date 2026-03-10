# frozen_string_literal: true

class CMS::SectionInput < Formtastic::Inputs::SelectInput
  def input_html_options
    super.merge(class: 'cms-section-picker')
         .reverse_merge(collection: collection)
  end

  def select_html
    paths = sections.partial_paths.to_h
    super << template.javascript_tag("
      const fn = () => { window.CMS.partialPaths(#{paths.to_json}); };
      if (document.readyState === 'complete') {
        fn();
      } else {
        document.addEventListener('DOMContentLoaded', fn);
      };
    ")
  end

  def options
    super.merge(include_blank: false)
  end

  private

  def sections
    @sections ||= template.current_account.sections
  end

  # :reek:TooManyStatements
  def collection
    all_sections = sections.to_a
    children_map = all_sections.group_by(&:parent_id)

    result = []
    stack = [[all_sections.find(&:root?), 0]]

    while (section, level = stack.pop)
      result << section_option(section, level)

      children_map.fetch(section.id, []).reverse_each do |child|
        stack.push([child, level + 1])
      end
    end

    result
  end

  # :reek:FeatureEnvy
  def section_option(section, level)
    prefix = section.root? ? '. ' : "|#{'&mdash;' * level} "
    [prefix.html_safe + h(section.title), section.id] # rubocop:disable Rails/OutputSafety
  end
end
