module ThreeScale::SpamProtection
  module Integration

    module FormBuilder
      # Just adds fields from spam protection module
      def spam_protection
        protection = @object.spam_protection
        protection.form(self).to_str
      end
    end

  end
end
