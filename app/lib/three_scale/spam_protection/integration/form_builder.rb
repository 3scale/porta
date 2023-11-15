module ThreeScale::SpamProtection
  module Integration

    module FormBuilder
      # Just adds fields from spam protection module
      def spam_protection
        template.controller.spam_protection_form(self).to_str
      end
    end

  end
end
