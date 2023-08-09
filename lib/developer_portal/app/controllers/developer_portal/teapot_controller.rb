# frozen_string_literal: true

module DeveloperPortal
  class TeapotController < ApplicationController
    def index
      @stuff = 'STUFF'
    end
  end
end
