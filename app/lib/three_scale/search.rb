class ThreeScale::Search < ActiveSupport::HashWithIndifferentAccess

  class FormBuilder < ActionView::Helpers::FormBuilder
    def fields_for(record_name, record_object = nil, fields_options = {}, &block)
      fields_options[:builder] ||= options[:builder]
      fields_options[:namespace] = options[:namespace]
      fields_options[:parent_builder] = self

      record_object ||= @object.send(record_name)
      record_name = "#{object_name}[#{record_name}]"

      @template.fields_for(record_name, record_object, fields_options, &block)
    end
  end

  def initialize(params = nil)
    hash_methods = %I[to_unsafe_h to_hash]
    to_hash_method = hash_methods.find { |method| params.respond_to?(method) }

    if to_hash_method
      params.public_send(to_hash_method).each_pair do |key, val|
        self[key] = val
      end
    end
    self.symbolize_keys!
    self.reject! { |key, val| val.blank? }
    self
  end

  # Assigns variables to a search object.
  #
  def method_missing(name, value=nil)
    key = name.to_s.sub(/[=?!]$/,'')

    if name.to_s.ends_with?("=")
      self[key] = value
    end

    value = self[key]

    # convert value to integer if key ends with _id
    if key.ends_with?("_id") && value.present?
      value.respond_to?(:map) ? value.map(&:to_i) : value.to_i
    else
      # convert hash to ThreeScale::Search so we can use it in nested forms
      value.respond_to?(:to_hash) ? self.class.new(value) : value
    end
  end


  # Scopes for models
  module Scopes
    def self.included(base)
      base.class_eval do
        with_options :instance_writer => false, :instance_reader => false do |config|
          config.class_attribute :allowed_sort_directions
          config.class_attribute :allowed_sort_columns
          config.class_attribute :default_sort_column, :default_sort_direction
          config.class_attribute :allowed_search_scopes
          config.class_attribute :default_search_scopes
          config.class_attribute :sort_columns_joins
        end

        self.allowed_sort_directions = [:ASC, :DESC]

        self.allowed_sort_columns = []
        self.allowed_search_scopes = []
        self.default_search_scopes = []

        self.sort_columns_joins = {}

        extend ClassMethods
      end
    end

    module ClassMethods

      def order_by(column = nil, direction = nil)
        column ||= default_sort_column
        direction ||= default_sort_direction

        return default_search_scope unless allowed_sort_columns
        return default_search_scope unless column.present? && allowed_sort_column?(column)

        order = table_and_column(column).join(".")

        join_columns = sort_column_joins(order)

        if direction.present? && allowed_sort_direction?(direction)
          order << " " << direction.to_s.upcase
        end

        # with scope overrides default scope
        reorder(order).scoping do
          join_columns.reduce(default_search_scope) do |scope, join|
            scope.joins{ |dsl| dsl.__send__(join).outer }
          end
        end
      end

      # scope_search is a bad name name, but #search is already taken by thinking-sphinx
      def scope_search(params, reduce = true)
        return default_search_scope unless allowed_scopes || default_search_scopes.present?
        return default_search_scope unless params

        params = params.dup
        # this escapes sphinx special characters like $
        params[:query] = Riddle.escape(params[:query]) if params[:query]

        selected_scopes = params.stringify_keys.slice(*allowed_scopes)

        Rails.logger.debug { "[search] Allowed scopes: #{allowed_scopes}" }
        Rails.logger.debug { "[search] Selected #{selected_scopes} from #{params}" }

        join_scopes(selected_scopes)
      end

      private

      def default_search_scope
        all
      end

      def allowed_scopes
        allowed_search_scopes.map(&:to_s).presence
      end

      def join_scopes(selected_scopes)
        # process default scopes - reduce all default scopes to one
        scope = default_search_scopes.inject(default_search_scope) do |scope, (method, args)|
          # skip default scope if it is used explicitly in params
          next scope if selected_scopes.include?(method.to_s)

          scope.send "by_#{method}", *args
        end

        # process selected scopes - reduce all scopes to one
        selected_scopes.inject(scope) do |scope, (method, args)|
          # skip if no params are supplied (nothing was selected or blank string given)
          next scope if args.blank?

          scope.send "by_#{method}", *args
        end
      end

      def allowed_sort_column?(column)
        table, column = table_and_column(column)

        allowed_sort_columns.any? do |col|
          tbl, col = table_and_column(col)
          tbl == table and col == column
        end
      end

      def allowed_sort_direction?(direction)
        allowed_sort_directions.include?(direction.to_s.upcase.to_sym)
      end

      def sort_column_joins(column)
        [ sort_columns_joins.symbolize_keys[column.to_sym] ].flatten.compact
      end

      def table_and_column(column)
        table, column = column.to_s.split(".")

        if table.present? && column.nil?
          column = table
          table = table_name
        end

        [ table, column ]
      end

    end # ClassMethods

  end # Scopes

  module Helpers

    MAX_PER_PAGE = 20

    def self.included(controller)
      controller.class_eval do
        helper_method :sort_column, :sort_direction
      end
    end

    def sort_column
      params[:sort]
    end

    def sort_direction
      params[:direction]
    end

    private

    def pagination_params
      { :page => params[:page] || 1, :per_page => per_page }
    end

    def per_page
      if params[:per_page].present? && params[:per_page].to_i <= MAX_PER_PAGE
        params[:per_page]
      else
        MAX_PER_PAGE
      end
    end

  end # Helpers
end
