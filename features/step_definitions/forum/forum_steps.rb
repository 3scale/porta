# frozen_string_literal: true

Given "the forum of {provider} is {public}" do |provider, public|
  provider.settings.update!(forum_public: public)
end
