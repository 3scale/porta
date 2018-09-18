namespace :search do
  desc 'HACK: manually requires the account model so that sphinx indexes it properly'
  task :fix_account => :environment do
    require 'app/models/account'
  end

  desc 'run the function to mark pages as searchable on every CMS::Page in the system'
  task :set_searchable_to_pages => :environment do
    CMS::Page.find_each do |page|
      searchable = page.is_searchable?

      if searchable != page.searchable
        page.class.update_all({:searchable => searchable}, {:id => page.id})
      end
    end
  end
end
