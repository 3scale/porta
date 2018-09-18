module CMS
  module BuiltinPagesSupport
    extend ActiveSupport::Concern

    DEFAULT_LIQUID_LAYOUT = 'main_layout'

    included do
      # (to be included in a controller) Sets prefix for builtin pages
      # used to render actions of that controller.
      #
      # Example:
      #
      # class NewSignupsController
      #   self.builtin_template_scope = 'signup'
      #    ...
      #   def show
      #    # renders system name 'signup/show'
      #   end
      #
      # end
      #
      class_attribute :builtin_template_scope
    end

    def find_builtin_static_page_layout
      system_name = [builtin_template_scope, action_name].compact.join('/')

      page = site_account.builtin_static_pages.find_by_system_name(system_name)
      layout = page.try!(:layout)

      # TODO: return directly DEFAULT_LIQUID_LAYOUT when those
      # the views tested by these cukes don't rely on it:
      #
      #   features/stats/provider_side.feature:24
      #   features/stats/provider_side.feature:39
      #   features/finance/credit_card_details_for_provider.feature:15
      #   features/finance/credit_card_details_for_provider.feature:26
      #   features/finance/credit_card_details_for_provider.feature:50
      #   features/authorization/provider_stats.feature:14
      #   features/authorization/provider_stats.feature:49
      #   features/stats/provider/top_applications.feature:21
      #   features/stats/provider_side.feature:31
      #
      layout ? layout.system_name : pick_buyer_or_provider_layout
    end
  end
end
