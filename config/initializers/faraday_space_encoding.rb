# frozen_string_literal: true

require 'oauth2'

# Preserve the space encoding used before the OAuth2 upgrade.
Faraday::Utils.default_space_encoding = '+'
