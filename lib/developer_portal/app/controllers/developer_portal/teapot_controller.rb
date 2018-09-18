require_dependency "developer_portal/application_controller"

module DeveloperPortal
  class TeapotController < ApplicationController
    def index
      @stuff = 'STUFF'
    end
  end
end
