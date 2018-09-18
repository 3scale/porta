module Liquid
  module Tags
    module Common

      # deprecated "This tag is deprecated, use the **flash** tag instead."
      def flash
        controller= @context.registers[:controller]
        Rails.logger.info "+++++++++++++++++ [Common]-- rendering flash: #{controller.flash}_____________"
        controller.send(:render_to_string, :partial => 'shared/flash', :formats => [:html], :locals => {:flash => controller.flash})
      end

      # deprecated "This tag is deprecated, use a CMS partial instead."
      def footer
        controller= @context.registers[:controller]
        Rails.logger.info "[Common]-- rendering footer"
        controller.render_to_string(:partial => 'shared/footer', :formats => [:html])
      end
    end
  end
end
