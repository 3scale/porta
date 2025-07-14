# frozen_string_literal: true

module ThreeScale
  module ErrorsToXml
    # This was deprecated with no replacement in rails 6. Because allegedly
    # nobody uses it. So we have to keep a copy until we completely stop
    # supporting XMLs in our APIs.
    # https://github.com/rails/rails/pull/32313
    #
    # Returns an xml formatted representation of the Errors hash.
    #
    #   person.errors.add(:name, :blank, message: "can't be blank")
    #   person.errors.add(:name, :not_specified, message: "must be specified")
    #   person.errors.to_xml
    #   # =>
    #   #  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    #   #  <errors>
    #   #    <error>name can't be blank</error>
    #   #    <error>name must be specified</error>
    #   #  </errors>
    def to_xml(options = {})
      to_a.to_xml({ root: "errors", skip_types: true }.merge!(options))
    end
  end
end
