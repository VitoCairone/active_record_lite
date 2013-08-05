class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attributes.each { |attr_name| attr_accessor attr_name }
    # # Could alternatively just re-splatify the arguments, i.e.,
    # attr_accessor *attributes
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    object_arr = []
    results.each do |row_hash|
      object_arr << self.new(row_hash)
    end
    object_arr.empty? ? nil : object_arr
  end

  def initialize(params = {})
    unless params.is_a?(Hash)
      raise "#{self.class} initializer passed non-hash argument: #{params}"
    end
    params.keys.each do |attr_name|
      unless self.class.attributes.include?(attr_name.to_sym)
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
      # send automatically applies .to_sym on first argument
      self.send("#{attr_name}=", params[attr_name])
    end
  end
end
