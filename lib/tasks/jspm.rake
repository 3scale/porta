all_jspm_assets = Pathname.glob(Rails.root.join('assets').join('*'))
                          .select(&:directory?)
                          .select { |dir| dir.each_child.any? }
                          .map(&:basename).map(&:to_s)

excluded_jspm_assets = %w( jspm_packages bundles utilities applications users )
packageless_jspm_assets = %w( applications/new.es6 users/permissions.es6 )

JSPM_MAPPING = {
  (all_jspm_assets + packageless_jspm_assets - excluded_jspm_assets).join(' + ') => 'all.js'
}.freeze

BUYER_JSPM_ASSETS = {
    'stats.js' => {
        global_name: 'Stats',
        files: ['stats/buyer/index.es6']
    }
}.freeze

namespace :jspm do
  task install: 'npm:install' do
    run 'jspm install'
  end

  namespace :build do
    BUYER_JSPM_ASSETS.each do |sfx_bundle_file, options|
      desc "builds a self executing bundle of #{options[:files]} with global variable name #{options[:global_name]}"
      task sfx_bundle_file, [] => [] do |_t, _args|
        bundle = 'lib/developer_portal/app/assets/javascripts/'
        run "jspm build #{options[:files].join(' + ')} #{bundle + sfx_bundle_file} --format global --global-name #{options[:global_name]} --no-mangle --minify"
        puts
        FileUtils.touch(bundle)
        run("which git >/dev/null && git add #{bundle} 2> /dev/null || true")
        puts
      end
    end
  end

  task build: BUYER_JSPM_ASSETS.keys.map { |k| "jspm:build:#{k}" }

  namespace :dev do
    file_create 'localhost.key' do
      run "openssl req -x509 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -days 30 -nodes -subj '/CN=*.3scale.net.lvh.me'"
    end

    desc 'Start jspm-dev-server on https://localhost:3001 forwarding to your http://localhosts:3000'
    task server: %w(localhost.key) do
      run 'jspm-dev-server --port 3001 --proxy http://localhost:3000'
    end
  end

  desc 'Prepare jspm for development. Deletes precompiled bundles.'
  task dev: [:install] do
    run 'rm -f assets/bundles/all.js'
  end

  namespace :bundle do
    JSPM_MAPPING.each do |source, destination|
      desc "compile jspm module #{source} to #{destination}"
      task source, [] => [] do |_t, _args|
        bundle = "assets/bundles/#{destination}"
        run "jspm bundle --production --no-mangle --minify --#{ENV.fetch('SOURCE_MAPS', 'skip')}-source-maps #{source} #{bundle}"
        puts
        FileUtils.touch(bundle)
        run("which git >/dev/null && git add #{bundle} 2> /dev/null || true")
        puts
      end
    end
  end

  task bundle: JSPM_MAPPING.keys.map { |k| "jspm:bundle:#{k}" }

  task precompile: [:bundle] do
    run 'rm -rf vendor/assets/jspm_packages/*.map'
    run 'rm -rf vendor/assets/jspm_packages/npm'
    run 'rm -rf vendor/assets/jspm_packages/github'
    run 'which git > /dev/null && git clean -f -x vendor/assets/jspm_packages/ || true'
  end

  def run(command)
    puts command.to_s
    system(command)
  ensure
    abort "failed to run #{command}, exited with #{$CHILD_STATUS.to_i}" if !$CHILD_STATUS || !$CHILD_STATUS.success?
  end
end

desc 'compile all jspm modules'
task jspm: %w(jspm:install jspm:bundle jspm:build)
