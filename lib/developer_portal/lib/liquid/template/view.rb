module Liquid
  class Template
    class View < ActionView::Template
      attr_reader :record

      def initialize(source, ident, handler, details)
        source ||= '' # in case template is nil
        super
        @record = details.fetch(:record)
      end

      def self.from(record, path, cms)
        ident   = [record.class.name, record.id, record.system_name, record.path].compact.join(' ')
        handler = ActionView::Template.registered_template_handler(:liquid)
        details = {
          virtual_path: path.to_s,
          updated_at: record.updated_at,
          format: record.mime_type,
          record: record
        }

        ::Rails.logger.debug { "Liquid::Template::View for #{path.inspect} - #{record.inspect}" }

        content = record.content(cms.try(:render_draft_content?))

        new(content, ident, handler, details)
      end

      def layout
        if layout = @record.try!(:layout).try!(:system_name)
          "layouts/#{layout}"
        end
      end

      def render(view, *args)
        super
      ensure
        # for example views does not have cms_toolbar
        # cant use short circuit return here as it overrides returned value
        if view.controller.respond_to?(:cms_toolbar)
          toolbar = view.controller.cms_toolbar

          if @record.is_a?(CMS::Layout)
            toolbar.layout = @record
          else
            toolbar.main_page = @record
          end
        end
      end

    end
  end
end
