require_relative './mass_object'
require_relative './associatable'
require_relative './db_connection'
# require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject

  extend Searchable

  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name
  end

  def self.all
    results = DBConnection.execute("SELECT * FROM #{table_name}")
    parse_all(results)
  end

  def self.find(id)
    query_str = "SELECT * FROM #{table_name} WHERE id = ?"
    row_hash = DBConnection.execute(query_str, id).first
    self.new(row_hash)
  end

  def save
    self.id.nil? ? create : update
  end

  private

  def create
    table_str = "#{self.class.table_name}"
    attribs = self.class.attributes - [:id]
    attr_str = "(#{attribs.join(", ")})"
    val_str = "(#{(["?"] * attribs.count).join(", ")})"
    query_str = "INSERT INTO #{table_str} #{attr_str} VALUES #{val_str}"
    DBConnection.execute(query_str, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    table_str = "#{self.class.table_name}"
    attribs = self.class.attributes - [:id]
    predicate_str = attribs.map { |attr_name| "#{attr_name} = ?" }.join(", ")
    query_str = "UPDATE #{table_str} SET #{predicate_str} WHERE id = ?"
    DBConnection.execute(query_str, *attribute_values, self.id)
  end

  def attribute_values
    attribs = self.class.attributes - [:id]
    attribs.map{ |attr_name| self.send(attr_name) }
  end

end
