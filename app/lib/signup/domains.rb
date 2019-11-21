# frozen_string_literal: true

module Signup
  class Domains
    def initialize(subdomain:, self_subdomain:)
      @subdomain = subdomain
      @self_subdomain = self_subdomain
    end
    attr_reader :subdomain, :self_subdomain
  end
end
