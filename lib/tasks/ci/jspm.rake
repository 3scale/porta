require 'diff/lcs'
require 'color'

namespace :ci do
  desc "Check that files in /assets/ are not newer than compiled bundles"
  task :jspm, [:files] do |_t, args|
    require Rails.root.join('app/lib/three_scale/diff')

    file_contents = ->(file) { [ file, File.read(file) ] }
    args = args.with_defaults(files: JSPM_MAPPING.values.map{|f| "assets/bundles/#{f}" } )

    git = args.fetch(:files).map(&file_contents).to_h

    tmpdir = Pathname(Dir.mktmpdir)
    backups = args.fetch(:files).map do |file|
      backup = tmpdir.join(file)
      backup.dirname.mkpath
      FileUtils.move(file, backup)
      puts "copied #{file} to #{backup}"
      [ backup, file]
    end.to_h

    JSPM_MAPPING.keys.each{ |b| Rake::Task["jspm:bundle:#{b}"].invoke } # without dependencies

    built = args.fetch(:files).map(&file_contents).to_h

    begin
      tmp = Rails.root.join('tmp', 'jspm')

      backups.each do |backup, original|
        generated = tmp.join(original)
        generated.dirname.mkpath
        FileUtils.move(original, generated)
        puts "saved #{generated}"
        FileUtils.move(backup, original)
      end
    rescue => e
      warn "error when recovering files: #{e}"
    end

    failures = []

    puts

    git.each_pair do |file, original|
      compiled = built[file]
      if compiled == original
        puts "#{file} is fresh and bundled"
      else
        puts "#{file} has following difference:"
        diff = ThreeScale::Diff.new(original, compiled)
        colored = diff.to_s.each_line.map do |line|
          case line
          when /^\-/ then "#{Color::GREEN}#{line}#{Color::CLEAR}"
          when /^\+/ then "#{Color::RED}#{line}#{Color::CLEAR}"
          else line
          end
        end.join
        puts colored
        failures << file
      end
    end

    if failures.any?
      puts Color::RED + Color::BOLD
      puts "See JSPM.md for more details. You might forgot `rake jspm:bundle`."
      puts
      abort "ERROR: Built jspm packages are not fresh: #{failures.to_sentence}#{CLEAR}"
    end
  end
end
