require_relative './db_connection'

module Searchable
  def where(params)
    clause = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    query_str = "SELECT * FROM #{table_name} WHERE #{clause}"
    results = DBConnection.execute(query_str, *(params.values) )
    parse_all(results)
  end
end