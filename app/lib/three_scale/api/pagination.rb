# frozen_string_literal: true

module ThreeScale::Api::Pagination
  def self.load_records(relation)
    relation.load_page_records if relation.respond_to?(:load_page_records)
    relation.to_ary
  end
end
