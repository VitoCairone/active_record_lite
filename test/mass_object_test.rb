require 'active_record_lite.rb'

class MyMassObject < MassObject
  set_attrs(:x, :y)
end

# obj = MyMassObject.new
# obj.x = 3
# p obj.x
# obj.y = 5
# p obj.y
# obj.x = 7
# p obj.x

obj = MyMassObject.new(:x => :x_val, :y => :y_val)
p obj

obj2 = MyMassObject.new("x" => "x_val", "y" => "y_val")
p obj2