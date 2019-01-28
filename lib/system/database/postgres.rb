# frozen_string_literal: true

require 'system/database/postgres/trigger'
require 'system/database/postgres/procedure'
require 'system/database/postgres/trigger_procedure'

module System
  module Database
    module Postgres
      include Definitions
    end
  end
end

require 'system/database/definitions/postgres'
