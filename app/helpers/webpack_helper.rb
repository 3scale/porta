# rubocop:disable Rails/HelperInstanceVariable
# frozen_string_literal: false

module WebpackHelper
  def load_webpack_manifest
    JSON.parse(File.read('public/packs/manifest.json'))
  rescue Errno::ENOENT
    raise "The webpack manifest file does not exist. Try running `rails assets:precompile`"
  end

  def webpack_manifest
    # Always get manifest.json on the fly in development mode
    return load_webpack_manifest if Rails.env.development?

    Rails.configuration.x.webpack.manifest ||= load_webpack_manifest
  end

  ##
  # Returns a string of HTML script and style tags, containing all chunks of one or more +packs+.
  # Chunks generated from ".ts" packs are located under the entrypoint with extension.
  # Chunks generated from ".scss" packs are located under the entrypoint without extension.
  #
  # +packs+ is a list of pack names, without extension (.ts, .js).
  #
  # FIXME: the entrypoints in manifest should not have extension .ts
  #
  # A RuntimeError is raised if one pack is not found in the manifest, possibly pointing out a typo.
  #
  def javascript_packs_with_chunks_tag(*packs) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    @packs ||= []
    tags = ''

    packs.each do |pack|
      entrypoint_with_extension = webpack_manifest['entrypoints']["#{pack}.ts"] || {}
      entrypoint_without_extension = webpack_manifest['entrypoints'][pack] || {}

      entrypoint = entrypoint_with_extension.deep_merge(entrypoint_without_extension) do |key, this_val, other_val|
        (this_val + other_val).uniq
      end
      raise "No entrypoint '#{pack}' in manifest" if entrypoint.empty?

      assets = entrypoint['assets']

      if (js = assets['js'])
        new_js_assets = js - @packs
        @packs.concat(new_js_assets)
        tags.concat(javascript_include_tag(*new_js_assets, defer: false), "\n")
      end

      if (css = assets['css']) # rubocop:disable Style/Next
        new_css_assets = css - @packs
        @packs.concat(new_css_assets)
        tags.concat(stylesheet_link_tag(*new_css_assets, defer: false))
      end
    end

    tags.html_safe # rubocop:disable Rails/OutputSafety
  end

  ##
  # Returns a string of HTML style tags, containing all CSS chunks of one or more +packs+.
  # Chunks generated from ".scss" packs are located under the entrypoint without extension.
  #
  # +packs+ is a list of pack names, without extension.
  #
  # A RuntimeError is raised if one pack is not found in the manifest, possibly pointing out a typo.
  #
  def stylesheet_packs_chunks_tag(*packs) # rubocop:disable, Metrics/MethodLength, Metrics/CyclomaticComplexity
    @packs ||= []
    tags = ''

    packs.each do |pack|
      entrypoint = webpack_manifest['entrypoints'][pack] || {}
      raise "No entrypoint '#{pack}' in manifest" if entrypoint.empty?

      assets = entrypoint['assets']

      next unless (css = assets['css'])

      new_css_assets = css - @packs
      @packs.concat(new_css_assets)
      tags += stylesheet_link_tag(*new_css_assets, defer: false)
    end

    tags.html_safe # rubocop:disable Rails/OutputSafety
  end
end

# rubocop:enable Rails/HelperInstanceVariable
