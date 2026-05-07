# frozen_string_literal: true

require 'test_helper'

class OracleHacksTest < ActiveSupport::TestCase
  setup do
    skip "Oracle-specific tests" unless System::Database.oracle?
  end

  class ArelTest < OracleHacksTest
    test "using #with_lock block" do
      object = FactoryBot.create(:audit)
      assert( object.with_lock { :ok } )
    end
  end

  class CollectionsTest < OracleHacksTest
    setup do
      messages = FactoryBot.create_list(:message, 1010, sender: master_account)
      @ids = messages.map(&:id)
    end

    test "should allow more than 1000 items using Arel::Nodes::In" do
      table = Message.arel_table
      in_node = Arel::Nodes::In.new(table[:id], @ids)
      query = table.where(in_node).project(Arel.star)

      sql = query.to_sql
      messages = Message.connection.select_all(sql).to_a

      assert_equal @ids.size, messages.size, "Expected to retrieve all #{@ids.size} messages"

      # SQL contains multiple IN clauses (split due to 1000 limit)
      in_clause_count = sql.scan(/IN \(/).size
      assert in_clause_count > 1, "Expected multiple IN clauses due to Oracle's 1000 item limit, but found #{in_clause_count}"
    end

    test "should allow more than 1000 items using raw Arel::Nodes::NotIn" do
      ids = @ids.dup
      non_not_in = ids.pop

      table = Message.arel_table
      not_in_node = Arel::Nodes::NotIn.new(table[:id], ids)
      query = table.where(not_in_node).project(Arel.star)

      sql = query.to_sql
      messages = Message.connection.select_all(sql).to_a

      assert_equal 1, messages.size, "Expected to retrieve exactly 1 message"
      assert_equal non_not_in, messages.first["id"], "Expected to retrieve the message with id #{non_not_in}"

      # SQL contains multiple NOT IN clauses (split due to 1000 limit)
      not_in_clause_count = sql.scan(/NOT IN \(/).size
      assert not_in_clause_count > 1, "Expected multiple NOT IN clauses due to Oracle's 1000 item limit, but found #{not_in_clause_count}"
    end
  end
end
