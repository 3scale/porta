Factory.define(:cms_template, :class => CMS::Template) do |t|
  t.association :provider, :factory => :provider_account
end

Factory.define(:cms_layout, :parent => :cms_template, :class => CMS::Layout) do |p|
  p.sequence(:system_name) { |n| "layout-#{n}" }
  p.title { |s| s.system_name }
end

Factory.define(:cms_partial, :parent => :cms_template, :class  => CMS::Partial) do |p|
  p.sequence(:system_name) { |n| "partial-#{n}" }
end

Factory.define :cms_section, :class => CMS::Section do |section|
  section.association :provider, :factory => :provider_account
  section.sequence(:title) { |n| "Section #{n}" }
  section.sequence(:system_name) { |n| "sysname #{n}" }
  section.partial_path { |section| "/#{section.title.parameterize}" }
  section.public true
end

Factory.define(:cms_portlet, :class => CMS::Portlet) do |portlet|
  portlet.sequence(:system_name) { |n| "portlet-#{n}" }
  portlet.association(:provider, :factory => :provider_account)
  portlet.portlet_type CMS::Portlet.available.first.to_s
  portlet.type CMS::Portlet.available.first.to_s
end

Factory.define :cms_group, :class => CMS::Group do |group|
  group.association :provider, :factory => :provider_account
  group.sequence(:name){|n| "Group #{n}"}
end

Factory.define :root_cms_section, :parent => :cms_section, :class => CMS::Builtin::Section do |section|
  section.title "Root Section"
  section.system_name "root"
  section.partial_path '/'
end

Factory.define :cms_email_template, :parent => :cms_template, :class => CMS::EmailTemplate do |email|
  email.sequence(:system_name) { |n| "email-template-#{n}" }
  email.published 'published content'
end

Factory.define :cms_file, :class => CMS::File do |file|
  file.sequence(:path) { |n| "/file-#{n}" }
  file.association(:provider, :factory => :provider_account)
  file.section { |f| f.provider && f.provider.builtin_sections.root }
  file.attachment { Rails.root.join('test', 'fixtures', 'hypnotoad.jpg').open }
end

Factory.define(:cms_page, :parent => :cms_template, :class => CMS::Page) do |p|
  # association is copied to child factory because we reference provider
  # and it is not yet created, but copying association to this factory fixes it
  p.association :provider, :factory => :provider_account
  p.sequence(:title) { |n| "page-#{n}" }
  p.sequence(:path) { |n| "/page-#{n}" }
  p.content_type 'text/html'
  p.section { |p| p.provider && p.provider.builtin_sections.root }
end

Factory.define(:cms_builtin_page, :parent => :cms_template, :class => CMS::Builtin::Page) do |p|
  p.sequence(:system_name) { |n| "builtin-page-#{n}" }
  p.section { |p| p.provider && p.provider.builtin_sections.root }
end

Factory.define(:cms_builtin_static_page, :parent => :cms_template, :class => CMS::Builtin::StaticPage) do |p|
  p.sequence(:system_name) { |n| "builtin-static-page-#{n}" }
  p.section { |p| p.provider && p.provider.builtin_sections.root }
end

Factory.define(:cms_builtin_partial, :parent => :cms_template, :class => CMS::Builtin::Partial) do |p|
  # pick a random *defined* system name as you cannot create new stuff of this kind.
  p.sequence(:system_name) do |n|
    CMS::Builtin::Partial.system_name_whitelist.sample
  end
end

Factory.define :cms_builtin_legal_term, :parent => :cms_builtin_partial, :class => CMS::Builtin::LegalTerm do |legal|
  legal.system_name 'signup_licence'
  legal.sequence(:title) { |n| "Legal Term ##{n}" }
  legal.published "some text"
end
