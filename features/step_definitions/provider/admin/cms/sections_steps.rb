# frozen_string_literal: true

Given "{provider} has the following section(s):" do |provider, table|
  parent = provider.sections.first || FactoryBot.create(:root_cms_section, provider: provider)

  transform_cms_sections_table(table)
  table.hashes.each do |options|
    FactoryBot.create(:cms_section, provider:,
                                    parent:,
                                    system_name: options[:title].parameterize,
                                    **options)
  end
end

#TODO: use test_helper TestHelpers::SectionsPermissions
Given "{buyer} has access to section {string} of {provider}" do |buyer, section_name, provider|
  group = FactoryBot.create(:cms_group, provider:)
  group.sections << provider.sections.find_by!(title: section_name)

  buyer.groups << group
end

Then "the {section_of_provider} should be access restricted" do |section|
  assert !section.public?
end
