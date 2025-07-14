# frozen_string_literal: true

namespace :assets do # rubocop:disable Metrics/BlockLength

  namespace :environment do
    task :observers do
      System::Application.configure do
        # do not load observers, because they load all models and require database access
        initializer 'stop.active_record.observer', after: 'active_record.observer' do
          ActiveSupport.on_load(:active_record) do
            ActiveRecord::Base.define_singleton_method(:instantiate_observers) { } # rubocop:disable Lint/EmptyBlock
          end
        end
      end
    end

    task :factory_bot do
      System::Application.configure do
        initializer 'factory_bot.reset_factory_paths',
                    after: 'factory_bot.set_factory_paths' do
          FactoryBot.definition_file_paths = [] if defined?(FactoryBot)
        end
      end
    end
  end

  desc "Clear assets compile cache"
  task :clear_cache do
    Rails.root.join('tmp/cache/assets').rmtree
  end

  Rake::Task['assets:environment'].enhance(%w[assets:environment:factory_bot assets:environment:observers])

  Rake::Task['assets:clobber'].enhance do
    FileUtils.rm 'public/packs/manifest.json', force: true
  end

  Rake::Task["assets:precompile"].enhance do
    Rake::Task["webpack:compile"].invoke
  end
end
