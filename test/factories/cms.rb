Factory.define do
  factory(:cms_template, :class => CMS::Template) do
    association :provider, :factory => :provider_account
  end

  factory(:cms_layout, :parent => :cms_template, :class => CMS::Layout) do
    sequence(:system_name) { |n| "layout-#{n}" }
    title { |s| s.system_name }
  end

  factory(:cms_partial, :parent => :cms_template, :class  => CMS::Partial) do
    sequence(:system_name) { |n| "partial-#{n}" }
  end

  factory :cms_section, :class => CMS::Section do
    ssociation :provider, :factory => :provider_account
    sequence(:title) { |n| "Section #{n}" }
    sequence(:system_name) { |n| "sysname #{n}" }
    partial_path { |section| "/#{section.title.parameterize}" }
    public true
  end

  factory(:cms_portlet, :class => CMS::Portlet) do
    sequence(:system_name) { |n| "portlet-#{n}" }
    association(:provider, :factory => :provider_account)
    portlet_type CMS::Portlet.available.first.to_s
    type CMS::Portlet.available.first.to_s
  end

  factory :cms_group, :class => CMS::Group do
    association :provider, :factory => :provider_account
    sequence(:name){|n| "Group #{n}"}
  end

  factory :root_cms_section, :parent => :cms_section, :class => CMS::Builtin::Section do
    title "Root Section"
    system_name "root"
    partial_path '/'
  end

  factory :cms_email_template, :parent => :cms_template, :class => CMS::EmailTemplate do
    sequence(:system_name) { |n| "email-template-#{n}" }
    published 'published content'
  end

  factory :cms_file, :class => CMS::File do
    sequence(:path) { |n| "/file-#{n}" }
    association(:provider, :factory => :provider_account)
    section { |f| f.provider && f.provider.builtin_sections.root }
    attachment { Rails.root.join('test', 'fixtures', 'hypnotoad.jpg').open }
  end

  factory(:cms_page, :parent => :cms_template, :class => CMS::Page) do
    # association is copied to child factory because we reference provider
    # and it is not yet created, but copying association to this factory fixes it
    association :provider, :factory => :provider_account
    sequence(:title) { |n| "page-#{n}" }
    sequence(:path) { |n| "/page-#{n}" }
    content_type 'text/html'
    section { |p| p.provider && p.provider.builtin_sections.root }
  end

  factory(:cms_builtin_page, :parent => :cms_template, :class => CMS::Builtin::Page) do
    sequence(:system_name) { |n| "builtin-page-#{n}" }
    section { |p| p.provider && p.provider.builtin_sections.root }
  end

  factory(:cms_builtin_static_page, :parent => :cms_template, :class => CMS::Builtin::StaticPage) do
    sequence(:system_name) { |n| "builtin-static-page-#{n}" }
    section { |p| p.provider && p.provider.builtin_sections.root }
  end

  factory(:cms_builtin_partial, :parent => :cms_template, :class => CMS::Builtin::Partial) do
    # pick a random *defined* system name as you cannot create new stuff of this kind.
    sequence(:system_name) do |n|
      CMS::Builtin::Partial.system_name_whitelist.sample
    end
  end

  factory :cms_builtin_legal_term, :parent => :cms_builtin_partial, :class => CMS::Builtin::LegalTerm do
    system_name 'signup_licence'
    sequence(:title) { |n| "Legal Term ##{n}" }
    published "some text"
  end
end
