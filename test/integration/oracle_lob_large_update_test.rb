# frozen_string_literal: true

require 'test_helper'

class OracleLobLargeUpdateTest < ActiveSupport::TestCase
  # Test large LOB (CLOB and BLOB) updates with OCI8::BindType::Long/LongRaw piecewise retrieval
  # This verifies the OCIConnectionCursorLobFix in config/initializers/oracle.rb works correctly
  # by using OCI8::CLOB.new() and OCI8::BLOB.new() for direct binding

  setup do
    skip "Only run on Oracle database" unless System::Database.oracle?

    @service = FactoryBot.create(:simple_service)
    @proxy = @service.proxy
  end

  test "update and retrieve large CLOB (policies_config) with 512KB data" do
    # Generate ~512KB of JSON data for policies_config
    large_policy_data = generate_large_policies_config(2.kilobytes)

    # Initial save using ActiveRecord
    @proxy.policies_config = large_policy_data
    @proxy.save!

    @proxy.reload
    retrieved_policies = @proxy.policies_config
    assert retrieved_policies.to_json.bytesize >= 2.kilobytes

    expected_policy = JSON.parse(large_policy_data).first
    assert_includes retrieved_policies.map(&:to_h), expected_policy

    # NOW UPDATE with different data
    large_policy_data_v2 = generate_large_policies_config(512.kilobytes, version: "2.0")
    @proxy.reload
    @proxy.policies_config = large_policy_data_v2
    @proxy.save!

    @proxy.reload
    retrieved_policies_v2 = @proxy.policies_config

    assert retrieved_policies_v2.to_json.bytesize >= 512.kilobytes

    expected_policy_v2 = JSON.parse(large_policy_data_v2).first
    assert_includes retrieved_policies_v2.map(&:to_h), expected_policy_v2
  end

  test "update and retrieve large BLOB (MemberPermission service_ids) with 512KB data" do
    # Simple test model double for MemberPermission to avoid the JSON serialization logic
    test_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'member_permissions'
    end

    small_binary_data = Random.bytes(2.kilobytes)
    test_record = test_class.create!(service_ids: small_binary_data)
    test_record.reload
    assert_equal small_binary_data, test_record.service_ids

    # NOW UPDATE with different random binary data
    large_binary_data = Random.bytes(512.kilobytes)
    test_record.service_ids = large_binary_data
    test_record.save!

    test_record.reload
    retrieved_value = test_record.service_ids

    assert_equal large_binary_data.bytesize, retrieved_value.bytesize,"Updated binary data size should match"
    assert_equal large_binary_data, retrieved_value,"Updated service_ids should match new binary data"
  end

  test "test large blobs inline quoting" do
    sizes = [
      15.kilobytes,  # within EXTENDED limit
      160.kilobytes  # Large size
    ]

    sizes.each do |size|
      inline_data = Random.bytes(size)
      blob_data = ActiveModel::Type::Binary::Data.new(inline_data)
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        quoted = conn.quote(blob_data)
        conn.execute("INSERT INTO member_permissions (id, service_ids) VALUES (member_permissions_seq.nextval, #{quoted})")
        res =  conn.uncached { conn.select_all("SELECT service_ids FROM member_permissions") }
        assert_equal inline_data, res.first["service_ids"]
        conn.exec_delete("DELETE member_permissions")
      end
    end
  end

  # practical max is 2GB - 8 bytes; can be increased with a OCI8::BLOB and CLOB fixes to write big data in chunks
  test "test large CLOBs inline quoting" do
    sizes = [
      8.kilobytes - 1,  # VARCHAR2 within EXTENDED limit
      160.kilobytes  # Large size
    ]

    sizes.each do |size|
      description = "\u20AC" * size # 3 bytes character because we use UTF8 instead of AL32UTF8
      # description = "\u{1F600}" * size # 3 bytes character because we use UTF8 instead of AL32UTF8
      large_data = ActiveRecord::Type::OracleEnhanced::Text::Data.new(description)
      conn = ActiveRecord::Base.connection
      quoted = conn.quote(large_data)
      conn.execute("update services SET description = #{quoted} where id=#{@service.id}")

      actual_description = @service.reload.description
      assert_equal description, actual_description, "CLOB size #{size} did not match"
    end
  end

  private

  # Generate large JSON policies config data
  def generate_large_policies_config(target_size, version="1.0")
    # Generate a test JSON and calculate actual overhead
    test_policy = {
      "name" => "test_policy",
      "version" => version,
      "configuration" => { "data" => "" },
      "enabled" => true
    }

    test_json = [test_policy].to_json
    padding_size = target_size - test_json.bytesize

    return test_json if padding_size <= 0

    test_policy["configuration"]["data"] = "X" * padding_size
    [test_policy].to_json
  end
end
