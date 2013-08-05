require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams

  attr_accessor :other_class_name, :primary_key, :foreign_key

  def other_class
    other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams

  def initialize(name, params)
    self.other_class_name = params[:class_name] || name.to_s.camelize
    self.primary_key = params[:primary_key] || :id
    self.foreign_key = params[:foreign_key] || "#{name}_id".to_sym
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    self.other_class_name = params[:class_name] ||
                            name.to_s.singularize.camelize
    self.primary_key = params[:primary_key] || :id
    self.foreign_key = params[:foreign_key] ||
                       "#{self_class.to_s.underscore}_id".to_sym
  end

  def type
    :has_many
  end
end

module Associatable

  def assoc_params
    @assoc_params ||= {}
    @assoc_params
  end

  def belongs_to(name, params = {})
    assoc_params[name] = BelongsToAssocParams.new(name, params)
    aps = assoc_params[name]

    define_method(name) do
      query_str = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.primary_key} = ?
      SQL
      results = DBConnection.execute(query_str, self.send(aps.foreign_key))
      aps.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    assoc_params[name] = HasManyAssocParams.new(name, params, self.class)
    aps = assoc_params[name]

    define_method(name) do
      query_str = <<-SQL
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.foreign_key} = ?
      SQL
      results = DBConnection.execute(query_str, self.send(aps.primary_key))
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    aps1 = assoc_params[assoc1]

    define_method(name) do
      aps2 = (aps1.other_class).assoc_params[assoc2]
      unless aps1.type == :belongs_to && aps2.type == :belongs_to
        raise "has_one_through is only defined on belongs_to associations"
      end
      query_str = <<-SQL
        SELECT #{aps2.other_table}.*
        FROM #{aps1.other_table} JOIN #{aps2.other_table}
        ON #{aps1.other_table}.#{aps2.foreign_key}
           = #{aps2.other_table}.#{aps2.primary_key}
        WHERE #{aps1.other_table}.#{aps1.primary_key} = ?
      SQL
      arg_val = self.send(aps1.foreign_key)
      results = DBConnection.execute(query_str, arg_val)
      aps2.other_class.parse_all(results)
    end
  end
end
