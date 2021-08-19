# frozen_string_literal: true

Given "the forum of {provider} is {public}" do |provider, public|
  provider.settings.update_attribute :forum_public, public
end
