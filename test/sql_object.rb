require 'active_record_lite'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  set_attrs(:id, :name, :owner_id)
end

class Human < SQLObject
  set_table_name("humans")
  set_attrs(:id, :fname, :lname, :house_id)
end

puts "Calling find"
p Human.find(1)
puts "Calling find"
p Cat.find(1)
puts "Calling find"
p Cat.find(2)

puts "Calling all"
p Human.all
puts "Calling all"
p Cat.all

puts "Calling new"
c = Cat.new(:name => "Gizmo", :owner_id => 1)
puts "Calling save"
c.save # create
puts "Fetching"
p Cat.find(3)

c.name = "Gizmo II"
puts "Calling save"
c.save # update
puts "Fetching"
p Cat.find(3)
