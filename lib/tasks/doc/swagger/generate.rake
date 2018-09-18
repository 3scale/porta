# frozen_string_literal: true

namespace :doc do
  namespace :swagger do

    def run_command(cmd)
      puts "--> executing: #{cmd}"
      system cmd or abort
    end

    namespace :generate do
      desc "Generates all swagger docs"
      task all: %i[analytics finance master accounts cms]

      task :analytics do
        cmd = 'bundle exec source2swagger -i app/controllers/stats -e "rb" -c "##~" -o doc/active_docs/.'
        run_command cmd
      end

      task :master do
        cmd = 'bundle exec source2swagger -i app/controllers/master/api -e "rb" -c "##~" -o doc/active_docs/.'
        run_command cmd
      end

      task :accounts do
        cmd = 'bundle exec source2swagger -i app/controllers/admin/api -e "rb" -c "##~" -o doc/active_docs/.'
        run_command cmd
      end

      task :finance do
        cmd = 'bundle exec source2swagger -i app/controllers/finance -e "rb" -c "##~" -o doc/active_docs/.'
        run_command cmd
      end

      task :cms do
        cmd = 'bundle exec sour --comment="##=" app/controllers/admin/api/cms/*.rb > doc/active_docs/cms.json'
        run_command cmd
      end
    end

    namespace :generate_for_preview do
      desc "Generates all swagger docs for preview purposes"
      task all: %i[analytics finance master accounts cms]

      task :analytics do
        cmd = 'bundle exec source2swagger -i app/controllers/stats -e "rb" -c "##~" -o doc/active_docs/preview/.'
        run_command cmd
      end

      task :master do
        cmd = 'bundle exec source2swagger -i app/controllers/master/api -e "rb" -c "##~" -o doc/active_docs/preview/.'
        run_command cmd
      end

      task :accounts do
        cmd = 'bundle exec source2swagger -i app/controllers/admin/api -e "rb" -c "##~" -o doc/active_docs/preview/.'
        run_command cmd
      end

      task :finance do
        cmd = 'bundle exec source2swagger -i app/controllers/finance -e "rb" -c "##~" -o doc/active_docs/preview/.'
        run_command cmd
      end

      task :cms do
        cmd = 'bundle exec sour --comment="##=" app/controllers/admin/api/cms/*.rb > doc/active_docs/preview/cms.json'
        run_command cmd
      end
    end

    namespace :validate do
      desc "Validate swagger 2.0 specs"
      task all: %i[analytics finance accounts]
      task :analytics do
        run_command "node_modules/.bin/swagger-tools validate doc/active_docs/analytics-s20.json"
      end

      task :finance do
        run_command "node_modules/.bin/swagger-tools validate doc/active_docs/finance-s20.json"
      end

      task :accounts do
        run_command "node_modules/.bin/swagger-tools validate doc/active_docs/accounts-s20.json"
      end
    end

  end
end
