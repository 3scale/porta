ruby '~> 2.3.0'

eval_gemfile 'Gemfile.base'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro', '~> 3.5.3', require: %w(sidekiq-pro sidekiq/pro/web)
end

# one of the license terms does not permit modifications and presents unclear risk to redhat
gem 'airbrake', '~> 4.3.3'

# one of the license terms does not permit modifications and presents unclear risk to redhat
# NewRelic RPM
# docs says it should be loaded latest as possible
group :production, :preview, :development do
  gem 'newrelic-redis'
  gem 'newrelic_rpm', '~>3.5'
  gem 'rpm_contrib'
end

gem '3scale_client', '~> 2.6.1', require: false
gem 'analytics-ruby', require: false

group :development, :test do
  gem 'bootsnap'

  # to generate the swagger JSONs
  gem 'sour', github: 'HakubJozak/sour', require: false
  # for `rake doc:liquid:generate` and similar
  gem 'source2swagger', git: 'https://github.com/3scale/source2swagger'

  platform :mri_20, :mri_21, :mri_22, :mri_23 do
    # we want to disable byebug for capybara because it hangs
    # see: https://github.com/deivid-rodriguez/byebug/issues/115
    # the issue is tracked as https://github.com/deivid-rodriguez/pry-byebug/issues/69
    # there is a possiblity to disable it by ENV variable & .pryrc
    # but first https://github.com/deivid-rodriguez/pry-byebug/pull/98
    # has to be merged
    # gem 'pry-byebug', require: false, install_if: ENV.fetch('DISABLE_PRY_BYEBUG', '0') == '0'
    gem 'pry-stack_explorer', require: false
  end
end
