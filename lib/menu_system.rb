# This module allows to control which menu item of the main menu is active
# (highlighted) on current page. It can be done in two ways: using before_action
# style class method or using instance method, both called +activate_menu+.
#
# Current active menu can be retrieved using helper method +active_menu+
#
# == Example
#
# Before filter style: This will activate menu item with +services+ and submenu +overview+, only for
# actions +index+ and +show+.
# Beware: before filters are prepended, so you cannot override too generic definition in subclasses or another before filter calls.
# Only way how you can override is skip_before_action(:activate_menu) or calling activate menu on instance level.
#
#  class AwesomeStuffController < ApplicationController
#    activate_menu :stuff, :overview, :only => [:index, :show]
#  end
#
#
# Instance method style: This will activate menu item +stuff+ and submenu +focus+ inside
# action +show+, but only if someone is logged in.
# And it will activate +focus+ submenu inside action +edit+, but not override activated menu item.
#
#  class AwesomeStuffController < ApplicationController
#    def show
#      activate_menu(:stuff, :focus) if logged_in?
#      # ...
#    end
#
#    def edit
#     activate_menu :submenu => :focus
#    end
#  end
#
# In view:
#   Look at MenuHelpers for menu_item, provider_submenu_item and others.
#

module MenuSystem
  protected

  def self.included(base)
    base.helper_method(:active_menu, :active_submenu, :active_sidebar, :active_menu?)
    base.extend(ClassMethods)
  end


  # Activate named menu or other levels of menus.
  #
  # == Examples
  #
  #  activate_menu :dashboard, :messages # will set both menu and submenu level
  #  activate_menu :submenu => :users # will set only submenu level
  #
  def activate_menu(*args)
    args = args.flatten

    # process arguments passed as hash
    active_menus.merge! args.extract_options!.symbolize_keys

    # process arguments passed as array
    [:main_menu, :submenu, :sidebar].each do |level|
      value = args.shift and active_menus[level] = value
    end
  end

  # Activate named submenu.
  def activate_submenu(name)
    activate_menu :submenu => name
  end

  def active_menu
    active_menus[:main_menu]
  end

  def active_submenu
    active_menus[:submenu]
  end

  def active_sidebar
    active_menus[:sidebar]
  end

  def active_menu?(level, title)
    return unless title.present?
    # opposite of #humanize: "Developer Portal => :developer_portal
    # and also "EndUser Plans" => :end_user_plans

    active_menus[level].try!(:to_s).try!(:underscore) == title.to_s.underscore.parameterize.underscore
  end

  private

  def active_menus
    @active_menus ||= {}
  end

  module ClassMethods
    # Specify which menu to activate in before_action fashion.
    #
    # == Examples
    #
    # activate_menu :account, :only => [:show, :edit, :update]
    #
    def activate_menu(*args)
      options = args.extract_options!.symbolize_keys
      args << options.slice!(:skip, :only, :except)

      # FIXME: this should not be prepend,
      # because if you call this in inherited object,
      # it will be overriden by parent
      prepend_before_action(options) do |controller|
        controller.send(:activate_menu, *args)
      end
    end

    # Version which does append filter and can override previously set values
    def activate_menu!(*args)
      options = args.extract_options!.symbolize_keys
      args << options.slice!(:skip, :only, :except)

      append_before_action(options) do |controller|
        controller.send(:activate_menu, *args)
      end
    end


    # DEPRECATED:
    #
    # use 'activate_menu( :main_item, :submenu_item, ...)'
    #
    def activate_submenu(name, params = {})
      prepend_before_action(params) do |controller|
        controller.send(:activate_submenu, name)
      end
    end


  end
end
