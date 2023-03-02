namespace :openshift do
  desc "Task to invoke on openshift pre hook"
  task :deploy => :environment do
    Rake::Task['openshift:check_writable'].invoke(Rails.root.join('public/system'))
    Rake::Task['db:deploy'].invoke
  end

  desc <<-DESC.strip_heredoc
Checks if the files in arguments are writable.
It uses glob so escape any comma and other expandable characters of your running shell

E.g.

  $ rake 'openshift:check_writable[{/var\,/tmp}]'

  Will raise this error:
    Writable paths check failed:
      - /var
DESC
  task :check_writable, [:files] do |t, args|
    paths = Pathname.glob(args[:files])
    paths.select! do |path|
      !FileTest.writable?(path)
    end

    raise <<-ERROR_MESSAGE.strip_heredoc if paths.any?
      Writable paths check failed:
        #{paths.map{|p| p.to_s.prepend('- ')}.join("\n")}
ERROR_MESSAGE
  end

  desc 'Task to invoke from OpenShift deployment post hook'
  task post_deploy: %i(backend:storage:enqueue_rewrite)

  namespace :thinking_sphinx do

    desc 'Start Thinking Sphinx engine with background index refreshing'
    task start: %i(environment) do
      interface = ThinkingSphinx::RakeInterface.new nodetach: true
      daemon = interface.daemon
      trap('INT') { daemon.stop }
      trap('TERM') { daemon.stop }
      at_exit { daemon.stop }

      interface.configure

      daemon.start
    end

    desc 'Generate configuration file for Thinking Sphinx engine'
    task configure: %i[environment] do
      ThinkingSphinx::RakeInterface.new(nodetach: true).configure
    end

    desc 'Cleanup pid and lock files from unclean shutdown'
    task cleanup: %i[environment] do
      indices_location = ThinkingSphinx::Configuration.instance.indices_location
      files = Dir.glob(File.join(indices_location, '*.{lock,pid}'))
      files.each(&FileUtils.method(:rm_f))
    end
  end

end
