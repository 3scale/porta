# frozen_string_literal: true

module Arel
  module Visitors
    Oracle.class_eval do
      # we need to strip ORDER from subqueries because Oracle does not support it
      def strip_order_from_select(o)
        case (node = o.right)
        when Arel::Nodes::SelectStatement
          node.orders = []
        end
      end

      def visit_Arel_Nodes_In(o, collector)
        strip_order_from_select(o)

        super
      end

      def visit_Arel_Nodes_NotIn(o, collector)
        strip_order_from_select(o)

        super
      end

      # Another wonderful piece.
      # Oracle can't compare CLOB columns with standard SQL operators for comparison.
      # We need to replace standard equality for text/binary columns to use DBMS_LOB.COMPARE function.
      # Fixes ORA-00932: inconsistent datatypes: expected - got CLOB
      def visit_Arel_Nodes_Equality(o, collector)
        case (left = o.left)
        when Arel::Attributes::Attribute
          column = column_for(left)

          case column.type
          when :text, :binary
            # https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_lob.htm#i1016668
            # returns 0 when the comparison succeeds
            comparator = Arel::Nodes::NamedFunction.new('DBMS_LOB.COMPARE', [left, o.right])
            collector = visit comparator, collector
            collector << ' = 0'
            collector
          else
            super
          end
        else
          super
        end

      end
    end
  end
end
