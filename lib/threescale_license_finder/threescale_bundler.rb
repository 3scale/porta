require 'license_finder/package_managers/bundler'

module LicenseFinder
  class ThreescaleBundler < Bundler

    private

    def definition
      @definition ||= ::Bundler.definition
    end
  end
end
