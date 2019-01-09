# frozen_string_literal: true

require 'percy/capybara'

ENV['PERCY_PARALLEL_TOTAL'] = ENV['PARALLEL_TEST_GROUPS']
ENV['PERCY_PARALLEL_NONCE'] = ENV['BUILD_TAG']

if defined?(Rails.application)
  # rubocop:disabloe
  Percy::Capybara::Loaders::NativeLoader.class_eval do
    def _get_image_resources
      resources = []
      image_urls = Set.new

      # Find all image tags on the page.
      page.all('img').each do |image_element|
        srcs = []
        srcs << image_element[:src] unless image_element[:src].nil?

        srcset_raw_urls = image_element[:srcset] || ''
        temp_urls = srcset_raw_urls.split(',')
        temp_urls.each do |temp_url|
          srcs << temp_url.split(' ').first
        end

        srcs.each do |url|
          image_urls << url
        end
      end

      raw_image_urls = _evaluate_script(page, _find_all_css_loaded_background_image_js)
      raw_image_urls.each do |raw_image_url|
        temp_urls = raw_image_url.scan(/url\(["']?(.*?)["']?\)/)
        # background-image can accept multiple url()s, so temp_urls is an array of URLs.
        temp_urls.each do |temp_url|
          url = temp_url[0]
          image_urls << url
        end
      end

      if @assets_from_stylesheets && @assets_from_stylesheets != :none
        image_urls.merge(@urls_referred_by_css.select { |path| @assets_from_stylesheets[path] })
      end

      image_urls.each do |image_url|
        # If url references are blank, browsers will often fill them with the current page's
        # URL, which makes no sense and will never be renderable. Strip these.
        next if image_url == current_path \
              || image_url == page.current_url \
              || image_url.strip.empty?

        # 3scale HACK on Percy: Do not match invalid data URL
        next if Percy::Capybara::Loaders::NativeLoader::DATA_URL_REGEX =~ image_url

        # Make the resource URL absolute to the current page. If it is already absolute, this
        # will have no effect.

        resource_url = URI.join(page.current_url, image_url).to_s

        # Skip duplicates.
        next if resources.find { |r| r.resource_url == resource_url }

        next unless _should_include_url?(resource_url)

        # Fetch the images.
        # TODO(fotinakis): this can be pretty inefficient for image-heavy pages because the
        # browser has already loaded them once and this fetch cannot easily leverage the
        # browser's cache. However, often these images are probably local resources served by a
        # development server, so it may not be so bad. Re-evaluate if this becomes an issue.
        response = _fetch_resource_url(resource_url)
        _absolute_url_to_relative!(resource_url, _current_host_port)
        next unless response

        resources << Percy::Client::Resource.new(
          resource_url, mimetype: response.content_type, content: response.body,
          )
      end
      resources
    end
  end
  # rubocop:enable

  # rubocop:disable Style/GlobalVars
  $percy = true if Percy::Capybara.initialize_build
end

at_exit do
  Percy::Capybara.finalize_build if $percy
end
