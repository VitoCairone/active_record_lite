require_relative './db_connection'

module Searchable


  class Relation
    attr_accessor :model_class, :where_values_hash

    def initialize(model_class, where_params)
      self.model_class = model_class
      self.where_values_hash = Hash.new([])
      self.where(where_params)
    end

    def where(where_params)
      where_params.each do |key, value|
        #Not sure why << value doesn't work here...
        @where_values_hash[key] += [value]
      end
      self
    end

    def unwrap()
      #construct flat arrays from the multi-value where clauses
      # since we only have = this is actually pointless
      # but it would make sense if we supported <, >, LIKE, and IN.
      where_what = []
      is_what = []
      where_values_hash.each do |key, multivalue|
        multivalue.each do |value|
          where_what << key
          is_what << value
        end
      end

      where_what = where_what.map { |what| "#{what} = ?" }.join(" AND ")
      query_str = "SELECT * FROM #{@model_class.table_name} WHERE #{where_what}"
      puts "QUERY = #{query_str}"
      results = DBConnection.execute(query_str, *is_what)
      @model_class.parse_all(results)
    end

    def method_missing(method_name, *args, &block)
      objects = self.unwrap()
      if objects.count == 1
        objects.first.send(method_name, *args, &block)
      else
        objects.send(method_name, *args, &block)
      end
    end

    def to_s
      self.unwrap().to_s
    end

    def inspect
      self.unwrap().inspect
    end
  end # end Relation class

  def where(params)
    Relation.new(self, params)
  end
end


# # Original Spec Solution
# module Searchable
#   def where(params)
#     clause = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
#     query_str = "SELECT * FROM #{table_name} WHERE #{clause}"
#     results = DBConnection.execute(query_str, *(params.values) )
#     parse_all(results)
#   end
# end