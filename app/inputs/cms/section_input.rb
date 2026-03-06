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

  def collection
    all_sections = sections.to_a
    root = all_sections.find(&:root?)
    children_map = all_sections.group_by(&:parent_id)

    build_section_options(root, children_map, 0)
  end

  def build_section_options(section, children_map, level)
    prefix = if section.root?
               '. '
             else
               "|#{'&mdash;' * level} "
             end

    children = children_map.fetch(section.id, []).flat_map do |child|
      build_section_options(child, children_map, level + 1)
    end

    [[prefix.html_safe + h(section.title), section.id], *children]
  end
end
