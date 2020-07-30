# frozen_string_literal: true

require 'test_helper'

class UriShortenerTest < ActiveSupport::TestCase
  test 'uri with long label' do
    shortener = UriShortener.new('http://this-hostname-label-is-longer-than-63-chars-which-is-not-allowed-according-to-rfc-1035.example.com')
    assert_equal 'http://this-hostname-label-is-longer-than-63-chars-which-is-no-a6ca0fb.example.com', shortener.call.to_s
  end

  test 'uri with multiple long labels' do
    shortener = UriShortener.new('http://this-hostname-label-is-longer-than-63-chars-which-is-not-allowed-according-to-rfc-1035.this-other-label-is-as-well-longer-than-63-chars-also-violating-the-rfc-1035.example.com')
    assert_equal 'http://this-hostname-label-is-longer-than-63-chars-which-is-no-a6ca0fb.this-other-label-is-as-well-longer-than-63-chars-also-v-57fa2c4.example.com', shortener.call.to_s
  end

  test 'does not duplicate leading dash' do
    shortener = UriShortener.new('http://long-system-name-that-will-cause-invalid-host-needs-to-be-63-chars-or-shorter.example.com')
    assert_not_equal 'http://long-system-name-that-will-cause-invalid-host-needs-to--4207987.example.com', shortener.call.to_s
    assert_equal     'http://long-system-name-that-will-cause-invalid-host-needs-to-4207987.example.com', shortener.call.to_s
  end

  test 'uri with no long labels' do
    shortener = UriShortener.new('http://this-label-is-ok.example.com')
    assert_equal 'http://this-label-is-ok.example.com', shortener.call.to_s
  end

  test 'invalid uri' do
    shortener = UriShortener.new('not a uri')
    refute shortener.call
  end
end
