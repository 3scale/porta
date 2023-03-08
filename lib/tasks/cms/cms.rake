namespace :cms do

  def for_all_providers(provider_id= nil)
    errors = []
    providers = (provider_id.to_i == 0) ? Account.providers : Account.providers.where(id: provider_id)
    providers.find_each(batch_size: 5) do |provider|
      begin
        puts "** Provider: #{provider.name}(id: #{provider.id})"
        yield(provider)
      rescue
        puts "Failed for #{provider.name}(#{provider.id}) - #{$!}"
        errors << provider.id
        raise if Rails.env.development?
      end
    end
    puts "Failed for #{errors.inspect}" unless errors.empty?
  end

  desc "Update builtin pages with the disk version unless changed"
  task :update_builtin_pages, [:provider_id, :system_name] => :environment do |t, args|
    for_all_providers(args[:provider_id]) do | provider |
      puts "** Provider: #{provider.name}(id: #{provider.id})"

      pages = if args[:system_name]
                provider.builtin_pages.where(system_name: args[:system_name])
              else
                provider.builtin_pages
              end

      pages.each do |page|
        new = CMS::Builtin::Page.filesystem_templates.fetch(page.system_name).read
        old = Pathname.new(CMS::Builtin::Page.filesystem_templates.fetch(page.system_name).to_s + '.old').read

        if old.gsub(/\W+/, '') == page.published.gsub(/\W+/, '')
          puts "\t++ updating #{page.system_name}."
          page.upgrade_content!(new)
        else
          puts "\t++ skipping #{page.system_name}."
          next
        end
      end
    end
  end

  desc 'Upgrade builtin partials with the disk version if not changed since creation'
  task :update_builtin_partials, [:provider_id, :system_name] => :environment do |t, args|
    for_all_providers(args[:provider_id]) do | provider |
      puts "** Provider: #{provider.name}(id: #{provider.id})"

      pages = if args[:system_name]
                provider.builtin_partials.where(system_name: args[:system_name]).where('created_at = updated_at')
              else
                provider.builtin_partials
              end

      pages.each do |page|
        new = CMS::Builtin::Partial.filesystem_templates.fetch(page.system_name).read
        puts "\t++ updating #{page.system_name}."
        page.upgrade_content!(new)
      end
    end
  end

  desc "Check if builtin pages were modified"
  task :check_builtin_pages, [:provider_id] => :environment do |t, args|
    for_all_providers(args[:provider_id]) do | provider |
      puts "** Provider: #{provider.name}(id: #{provider.id})"
      provider.builtin_pages.each do | page |
        unless CMS::Builtin::Page.filesystem_templates[page.system_name]
          puts "\t++ #{page.system_name} does not exist anymore"
          next
        end

        original_content = CMS::Builtin::Page.filesystem_templates.fetch(page.system_name).read
        next if original_content.gsub(/\W+/, '') == page.published.gsub(/\W+/, '')

        puts "\t++ #{page.system_name} is different than disk version [changes: #{original_content.size - page.published.size}]"
        # puts "\t===> ORIGINAL <===\n#{original_content}\n\t===> CURRENT <===\n#{page.published}\n"

      end
    end
  end

  desc "Create missing rails view paths"
  task create_missing_rails_view_paths: :environment do
    CMS::Template.where(rails_view_path: nil).find_each do |template|
      puts template.id

      if (path = template.send(:set_rails_view_path))
        template.update_column(:rails_view_path, path)
      end
    end
  end

  desc 'Replaces {% submenu %} with {% include "submenu" %} in templates'
  task :replace_submenu_tag, [:provider_id, :system_name] => :environment do |t, args|
    for_all_providers do |provider|
      provider.templates.find_each do |tmpl|
        next unless tmpl.published
        matches = tmpl.published.gsub(/{%\s*submenu\s*%}/)

        if matches.count > 0
          new = matches.each do |match|
            puts "\t++ Replacing #{match} in #{tmpl.id}/#{tmpl.system_name}"
            '{% include "submenu" %}'
          end

          tmpl.upgrade_content!(new)
        end
      end
    end
  end

  desc "Create missing static pages"
  task create_missing_static_pages: :environment do
    for_all_providers do |provider|
      SimpleLayout.new(provider).import_static_pages!
    end
  end

  desc "Delete a specific builtin static page"
  task :delete_builtin_static_page, [:provider_id, :system_name] => :environment do |t, args|
    if args[:system_name].blank?
      puts "provide the system_name of the builtin page you wish to delete"
      exit
    end

    for_all_providers(args[:provider_id]) do |provider|
      before = provider.builtin_static_pages.count
      system_name = args[:system_name]
      provider.builtin_static_pages.where(system_name: system_name).delete_all
      after  = provider.builtin_static_pages(true).count
      puts "\t++Deleted: #{before - after} buildin page(s)"
    end
  end

  desc "Add missing builtin pages and partials"
  task :create_missing_builtin_pages, [:provider_id] => :environment do |t, args|
    failed_provider_ids = []
    for_all_providers(args[:provider_id]) do |provider|
      begin
        before = provider.builtin_pages.count + provider.builtin_partials.count
        SimpleLayout.new(provider).create_builtin_pages_and_partials!
        after  = provider.builtin_pages.count + provider.builtin_partials.count
        puts "\t++Created: #{after - before} new buildin page(s)" unless after == before
      rescue ActiveRecord::RecordInvalid
        puts "Failed for #{provider.name}(#{provider.id}) - #{$!}"
        failed_provider_ids << provider.id
        next
      end
    end
    puts "Failed for #{failed_provider_ids.inspect}" unless failed_provider_ids.empty?
  end

  desc "Setup Error Layout"
  task :setup_error_layout => :environment do
    for_all_providers do |provider|
      SimpleLayout.new(provider).setup_error_layout!
    end
  end

  desc "Add search builtin page"
  task :add_search_builtin_page => :environment do
    Account.providers.find_each do |provider|
      next if provider.builtin_static_pages.find_by_system_name "search/index"
      next unless provider.sections.find_by_system_name "root"
      section = provider.sections.create! :parent => provider.sections.root, :partial_path => '/search', :title => 'Search', :system_name => 'Search'

      layout = provider.layouts.find_by_system_name("search_results") || provider.layouts.find_by_system_name("main_layout")
      page = provider.builtin_static_pages.new
      page.section = section
      page.system_name = "search/index"
      page.layout = layout
      page.save!
    end
  end

  namespace :fix do
    desc 'Replaces {% include "login/cas" %} with {% include "login/cas" with cas %} in templates'
    task :cas_and_pagination, [:provider_id, :system_name] => :environment do |_, args|
      for_all_providers(args[:provider_id]) do |provider|
        CMS::UpgradeContentWorker.enqueue(provider, :include)
      end
    end

    desc 'Fixes missing "," in link_to'
    task link_to_invoice: :environment do
      for_all_providers do |provider|
        if page = provider.builtin_pages.find_by_system_name('invoices/index')
          new = page.content.sub('link_to: invoice.pdf_url title', 'link_to: invoice.pdf_url, title')
          page.upgrade_content!(new)
          puts "\t++ Fixing link_to in #{page.id}/#{page.system_name}"
        end

        if page =  provider.builtin_pages.find_by_system_name('invoices/show')
          new = page.content.sub('link_to: invoice.pdf_url title', 'link_to: invoice.pdf_url, title')
          page.upgrade_content!(new)
          puts "\t++ Fixing link_to in #{page.id}/#{page.system_name}"
        end
      end
    end

    desc 'Fix pagination href attribute'
    task pagination_href: :environment do
      CMS::Partial.where(system_name: 'shared/pagination').find_each do |page|
        page.build_version(updated_by: '[3scale System]')
        page.published = page.content.sub('href="{{ part.link }}"', 'href="{{ part.url }}"')
        page.save(validate: false)

        puts "\t++ Fixing pagination href in #{page.id}/shared/pagination"
      end
    end
  end

  desc 'Reupload 3scale.js that were created because of #7503'
  task :reupload_3scalejs => :environment do
    pages = CMS::Page.where { created_at >= Date.parse('2016-07-26') }
    pages = pages.where(title: '3scale.js', path: '/javascripts/3scale.js')

    original_content = DeveloperPortal::VIEW_PATH.join('javascripts/3scale.js').read

    pages.find_each do |page|
      puts "Processing #{page.provider_id}"
      page.upgrade_content!(original_content)
    end
  end
end
