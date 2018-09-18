require 'license_finder'
require_relative 'jspm'
require_relative 'threescale_bundler'

module LicenseFinder
  module ThreescalePackageManager
    module ClassMethods
      def package_managers
        super + [JSPM, ThreescaleBundler] - [Bundler, NPM]
      end
    end

    def self.prepended(base)
      super
      class << base
        prepend ClassMethods
      end
    end
  end

  LicenseFinder::PackageManager.prepend(ThreescalePackageManager)
end

