class CMS::Sidebar
  include Rails.application.routes.url_helpers

  def initialize(provider)
    @provider = provider
  end

  def sections
    @sections ||= @provider.sections.select('id, system_name, title, parent_id, tenant_id, type').order(:title)
  end

  def builtins
    @builtins ||= @provider.builtins.select('id, title, system_name, tenant_id, section_id, type').order(:title)
  end

  def files
    @files ||= @provider.files.select('id, attachment_file_name, path, tenant_id, section_id').order(:path)
  end

  def pages
    @pages ||= @provider.pages.select('id, title, path, tenant_id, section_id').order(:title)
  end

  def partials
    @partials ||= @provider.all_partials.select('id, title, options, system_name, tenant_id, type').order(:system_name)
  end

  def layouts
    @layouts ||= @provider.layouts.select('id, title, system_name, tenant_id').order(:system_name)
  end

  def portlets
    @portlets ||= @provider.portlets.select('id, title, system_name, tenant_id, options')
  end

  def as_json(options = {})
    {
      root: root_paths,
      sections: array_as_json(sections),
      pages: array_as_json(pages),
      files: array_as_json(files),
      builtins: array_as_json(builtins),
      layouts: array_as_json(layouts),
      partials: array_as_json(partials),
      portlets: array_as_json(portlets)
    }
  end

  def last_update
    templates = [
        @provider.templates,
        @provider.files,
        @provider.sections,
        @provider.redirects,
    ]

    latest = templates.map { |associaton| associaton.maximum(:updated_at) }

    latest.compact.max
  end

  private

  def root_paths
    if root.present?
      root.as_json(except: :tenant_id)
        .deep_merge('section' => { edit_path: polymorphic_path([:edit, :provider, :admin, root])})
    end
  end

  def root
    @root ||= sections.root
  end

  def array_as_json(array)
    array.map do |model|
      model
        .as_json(except: :tenant_id, methods: [:search, :model], root: false)
        .merge(edit_path: polymorphic_path([:edit, :provider, :admin, model]))
    end
  end

end
