module ForumSupport
  # Mix in this module into admin-side controllers (forum, topic, post, ...)
  module Admin
    def self.included(base)
      base.extend(ClassMethods)

      base.before_action :ensure_provider_domain
      base.before_action :find_forum

      base.prefix_routes :admin_, :forum,
                                  :forum_topics, :forum_topic,
                                  :forum_topic_posts, :forum_posts, :forum_post,
                                  :forum_categories, :forum_category,
                                  :forum_subscriptions, :forum_subscription

      base.alias_route :new_forum_topic,      :new_admin_forum_topic
      base.alias_route :edit_forum_topic,     :edit_admin_forum_topic

      base.alias_route :new_forum_topic_post, :new_admin_forum_topic_post
      base.alias_route :edit_forum_post,      :edit_admin_forum_post

      base.alias_route :new_forum_category,   :new_admin_forum_category
      base.alias_route :edit_forum_category,  :edit_admin_forum_category

      base.alias_route :my_forum_topics,      :my_admin_forum_topics
    end

    private

    def find_forum
      @forum = domain_account.forum!
    end

    module ClassMethods
      # TODO: extract this to module/plugin.
      # TODO: document how to use this.
      # TODO: test this!
      #
      def alias_route(new_name, old_name, &block)
        raise "new name must be different from the old one" if new_name == old_name

        define_route_alias(:path, new_name, old_name, &block)
        define_route_alias(:url, new_name, old_name, &block)
      end

      # Convenience method for the common case of aliasing a route by prefixing it.
      #
      # Note: The non-prefixed routes alias the prefixed ones, not the other way around:
      #
      #   # :blogs_path will be alias for :admin_blogs_path
      #   prefix_routes :admin_, :blogs, :posts
      #
      # Warning: Currently does not work with new_ and edit_ routes correctly.
      def prefix_routes(prefix, *routes)
        routes.each do |route|
          alias_route route, "#{prefix}#{route}".to_sym
        end
      end

      private

      def define_route_alias(type, new_name, old_name, &block)
        name = "#{new_name}_#{type}"

        define_method(name) do |*args|
          dynamic_args = block ? block.bind(self).call : []
          dynamic_args = [dynamic_args] unless dynamic_args.is_a?(Array)

          send("#{old_name}_#{type}", *(dynamic_args + args))
        end

        helper_method name
        private name
      end
    end
end
end
