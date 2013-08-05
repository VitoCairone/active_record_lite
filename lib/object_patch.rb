class Object
  def new_attr_accessor(*attrs)
    attrs.each do |attr|
      ivar = "@#{attr}".to_sym
      define_method(attr) { instance_variable_get(ivar) }
      define_method("#{attr}=".to_sym) { |val| instance_variable_set(ivar, val) }
    end
  end
end

class Dog
  new_attr_accessor :name, :age, :breed
end