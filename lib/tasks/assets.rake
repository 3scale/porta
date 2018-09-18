namespace :assets do

  namespace :environment do
    task :observers do
      System::Application.configure do
        # do not load observers, because they load all models and require database access
        initializer 'stop.active_record.observer', after: 'active_record.observer' do
          ActiveSupport.on_load(:active_record) do
            ActiveRecord::Base.define_singleton_method(:instantiate_observers) { }
          end
        end
      end
    end

    task :factory_girl do
      System::Application.configure do
        initializer 'factory_girl.reset_factory_paths',
                    after: 'factory_girl.set_factory_paths' do
          if defined?(FactoryGirl)
            FactoryGirl.definition_file_paths = []
          end
        end
      end

    end
  end

  desc "Clear assets compile cache"
  task :clear_cache do
    Rails.root.join('tmp', 'cache', 'assets').rmtree
  end

  Rake::Task['assets:environment'].enhance(%w(assets:environment:factory_girl assets:environment:observers))
end
