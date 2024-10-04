# frozen_string_literal: true

require 'test_helper'

class WebpackHelperTest < ActionView::TestCase
  include WebpackHelper

  test 'unknown pack raise an error' do
    assert_raise(RuntimeError) do
      javascript_packs_with_chunks_tag('unknown')
    end

    assert_raise(RuntimeError) do
      stylesheet_packs_chunks_tag('unknown')
    end
  end

  test 'javascript_packs_with_chunks_tag' do
    tags = javascript_packs_with_chunks_tag('application')

    assert_equal 6, tags.lines.size
  end

  test 'stylesheet_packs_chunks_tag' do
    tags = stylesheet_packs_chunks_tag('application')

    assert_equal 1, tags.lines.size
  end

  private

  def webpack_manifest # rubocop:disable Metrics/MethodLength
    JSON.parse({
      entrypoints: {
        application: {
          assets: {
            js: [
              'packs/js/application-1.js',
              'packs/js/application-2.js',
            ],
            css: [
              'packs/css/application-1.css',
            ]
          }
        },
        'application.ts': {
          assets: {
            js: [
              'packs/js/application.ts-1.js',
            ],
            css: [
              'packs/css/application.ts-1.css',
              'packs/css/application.ts-2.css',
            ]
          }
        }
      }
    }.to_json)
  end
end
