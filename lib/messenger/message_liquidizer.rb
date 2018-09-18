module Messenger

  # This functionality is extracted to module because then also "normal"
  # Mailer (like InvitationMailer) can use it liquid template.
  #
  # REQUIRED METHODS: full_template_name, current_liquid_templates
  #
  # TODO: make most of the methods protected/private
  #
  module MessageLiquidizer

    # include Liquidizer
    include Liquid::Assigns

    def infer_drop_class(value)
      "Liquid::Drops::#{value.class}".constantize
    rescue NameError
    end

    def find_liquid_template(name)
      templates = current_liquid_templates
      # current_liquid_templates now can return nil, true, false or other stuff
      # so to prevent errors check for find_by_name method
      templates.find_by_name(name) if templates.respond_to?(:find_by_name)
    end

    def find_and_parse_body(*args)
      registers = args.extract_options!
      body = args.first

      template = find_liquid_template(full_template_name)
      content_to_parse = body || template.try!(:content)
      parsed_content = Liquid::Template.parse(content_to_parse)

      if (message = registers[:message]) && template
        message.extend(CMS::EmailTemplate::MessageExtension)
        message.apply_headers(template)
      end

      if (mailer = registers[:mailer]) && template
        mailer.extend(CMS::EmailTemplate::MailerExtension)
        mailer.send(:apply_headers, template)
      end

      if parsed_content
        parsed_content.render!(assigns_for_liquify, :registers => registers)
      else
        Rails.logger.warn("Message '#{full_template_name}' has empty body")
        nil
      end
    end

    def file_system
      file_system = Liquidizer::FileSystem.new { LiquidTemplate }
    end

  end
end
