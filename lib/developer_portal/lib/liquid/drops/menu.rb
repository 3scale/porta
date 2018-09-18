module Liquid
  module Drops
    class Menu < Drops::Base

      allowed_name :_menu, :menu

      def initialize(menus)
        @active = menus.dup
      end

      # Whole hash with all selected menu levels
      #
      attr_reader :active

      # Current active top level menu
      #
      def active_menu
        active[:main_menu].try(:to_s)
      end

      # Current active second level menu
      #
      def active_submenu
        active[:submenu].try(:to_s)
      end

      # Current active sidebar
      #
      def active_sidebar
        active[:sidebar].try(:to_s)
      end

    end
  end
end
