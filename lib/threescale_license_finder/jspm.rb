require 'license_finder'
require 'net/http'
require 'json'

module LicenseFinder
  class JspmPackages
    def self.packages
      list = `jspm inspect`.scan(/\s+(?<repo>\w+):(?<name>\S+)\s(?<version>\d[\.\d\w\-\s]+\S)\n/).map { |(repo, name, versions)| {repo: repo, name: name, versions: versions.split(' ')} }
      list.push(systemjs_package)
    end

    def self.systemjs_package
      version = File.read(File.expand_path('../../../assets/jspm_packages/.loaderversions', __FILE__))
      {repo: 'npm', name: 'systemjs', versions: [version]}
    end
  end

  class JSPM < NPM
    def current_packages
      packages = {}
      dependencies.each do |dependency|
        package_id = dependency.fetch('name') { raise "invalid dependency: #{dependency}" }
        packages[package_id] ||= NpmPackage.new(dependency, logger: logger)
      end
      packages.values
    end

    private

    def dependencies
      packages = JspmPackages.packages.each
      packages.map do |package|
        package[:repo] == 'npm' ? npm_dependency(package) : gh_dependency(package)
      end.flatten.compact
    end

    def gh_dependency(package)
      package[:versions].map { |version| gh_json(package[:name], version) }
    end

    def npm_dependency(package)
      package[:versions].map { |version| npm_json("#{package[:name]}@#{version}") }
    end

    def gh_json(name, version)
      ["git@github.com:#{name}.git#v#{version}", "git@github.com:#{name}.git"].each do |gh_url|
        package = package_json(gh_url)
        return package if package
      end
      raise "Failed to get package.json for #{name}@#{version}"
    end

    def package_json(gh_url)
      uri = URI(`node -e "console.log(require('hosted-git-info').fromUrl('#{gh_url}').file('package.json'))"`.strip)
      request = Net::HTTP.new(uri.host, uri.port)
      request.use_ssl = (uri.scheme == 'https')
      response = request.get(uri)
      JSON.parse response.body if response.code == '200'
    end

    def npm_json(package)
      command = "npm info #{package} --json --long"
      output, success = Dir.chdir(project_path) { capture(command) }
      success ? JSON(output) : parse_json(command, output)
    end

    def parse_json(command, output)
      json = begin
        JSON(output)
      rescue JSON::ParserError
        nil
      end
      raise "Command '#{command}' failed to execute: #{output}" unless json
      $stderr.puts "Command '#{command}' returned an error but parsing succeeded."
      json
    end
  end
end
