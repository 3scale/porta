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

      # remove once fixed in https://github.com/rsim/oracle-enhanced/pull/2573 (8.1.4+)
      # Note that I'm not fully happy with this as the other visitor is missing potential
      # patches that we have in this visitor. But limit+lock should be rare and simpler.
      # An example failing operation without this is ProxyRule#move_to_top
      def visit_Arel_Nodes_SelectStatement(o, collector)
        if o.limit && o.lock
          @oracle11_visitor ||= Arel::Visitors::Oracle.new(@connection)
          return @oracle11_visitor.accept(o.dup, collector)
        end
        super
      end

      # can remove both after upgrade to a version with (8.1.4+ perhaps)
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
        or_node = in_nodes.reduce { |left, right| Arel::Nodes::Or.new(left, right) }
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
        visit(Arel::Nodes::And.new(not_in_nodes), collector)
      end
    end
  end
end
