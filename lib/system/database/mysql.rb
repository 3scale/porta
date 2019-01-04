# frozen_string_literal: true

require 'system/database/mysql/trigger'
require 'system/database/mysql/procedure'

module System
  module Database
    module MySQL
      include Definitions
    end
  end
end

require 'system/database/definitions/mysql'
