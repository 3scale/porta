# Utilities for:
#
# https://github.com/HakubJozak/sour
#
module Threescale
  module Api
    module Sour
      module Operation
        def paginated
          param 'page',
          description: 'Current page of the list',
          dataType: 'int',
          paramType: "path",
          default: 1

          param 'per_page',
          description: 'Total number of records per one page (maximum 100)',
          dataType: 'int',
          default: 20
        end

        def param_system_name
          param 'system_name', 'Human readable and unique identifier'
        end

        def requires_access_token
          param 'access_token',
          description: 'Your access token',
          dataType: 'string',
          required: true,
          allowMultiple: false
        end
      end
    end
  end
end
