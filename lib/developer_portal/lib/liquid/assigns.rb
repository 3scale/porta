module Liquid
  module Assigns

    def assigns_for_liquify
      defined?(super) ? super : @_assigned_drops || {}
    end

    def assign_drops drops
      assigns = (@_assigned_drops ||= {})

      drops.stringify_keys.each do |name, drop|
        next if drop.nil?

        unless drop.respond_to?(:to_liquid)
          drop = Liquid::TemplateSupport.fetch_drop(name).wrap(drop)
        end

        if assigns.has_key?(name)
          raise "Cannot reassign existing variable #{name} with #{drop}"
        end

        unless drop.class.respond_to?(:allowed_name?)
          if drop.respond_to?(:to_liquid)
            assigns[name] = drop
            Rails.logger.warn "#{drop.inspect} assigned to #{name} without allowed_name? check."
          else
            Rails.logger.warn "#{drop.inspect} does not respond to allowed_name?. Skipping."
          end

          next
        end

        # regular drops in regular variables
        if drop.class.allowed_name?(name)
          assigns[name] = drop

        # drops assigned to deprecated variables
        elsif drop.class.deprecated_name?(name)
          assigns[name] = Liquid::Drops::Deprecated.wrap(drop)

        # drops assigned to not allowed variables
        else
          report_and_supress_exceptions do
            raise "#{drop} cannot be assigned to #{name}"
          end
        end
      end
    end

  end
end
