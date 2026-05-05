# frozen_string_literal: true

module Arel
  module Visitors
    Oracle12.class_eval do
      # Another wonderful piece.
      # Oracle can't compare CLOB columns with standard SQL operators for comparison.
      # We need to replace standard equality for text/binary columns to use DBMS_LOB.COMPARE function.
      # Fixes ORA-00932: inconsistent datatypes: expected - got CLOB
      # remove when https://github.com/rsim/oracle-enhanced/pull/2415 is merged
      def visit_Arel_Nodes_Equality(o, collector)
        left = o.left
        right = o.right

        return super unless right && %i(text binary).include?(cached_column_for(left)&.type)

        comparator = Arel::Nodes::NamedFunction.new("DBMS_LOB.COMPARE", [left, right])
        collector = visit comparator, collector
        collector << " = 0"
        collector
      end

      # remove when addressed: https://github.com/rsim/oracle-enhanced/pull/2247 - included in v7.1.0
      def visit_Arel_Nodes_Matches o, collector
        if !o.case_sensitive && o.left && o.right
          o.left = Arel::Nodes::NamedFunction.new('UPPER', [o.left])
          o.right = Arel::Nodes::NamedFunction.new('UPPER', [o.right])
        end

        super o, collector
      end

      # Remove after upgrade to a version with
      # https://github.com/rsim/oracle-enhanced/pull/2654
      def visit_Arel_Nodes_In(o, collector)
        attr, values = o.left, o.right
        return super unless values.is_a?(Array)

        in_clause_length = @connection.in_clause_length
        return super if values.length <= in_clause_length

        # Split into multiple IN nodes and combine with OR
        in_nodes = values.each_slice(in_clause_length).map do |slice|
          Arel::Nodes::In.new(attr, slice)
        end
        or_node = in_nodes.reduce { |left, right| Arel::Nodes::Or.new([left, right]) }
        visit(Arel::Nodes::Grouping.new(or_node), collector)
      end

      def visit_Arel_Nodes_NotIn(o, collector)
        attr, values = o.left, o.right
        return super unless values.is_a?(Array)

        in_clause_length = @connection.in_clause_length
        return super if values.length <= in_clause_length

        # Split into multiple NOT IN nodes and combine with AND
        not_in_nodes = values.each_slice(in_clause_length).map do |slice|
          Arel::Nodes::NotIn.new(attr, slice)
        end
        and_node = not_in_nodes.reduce { |left, right| Arel::Nodes::And.new([left, right]) }
        visit(and_node, collector)
      end
    end
  end
end
