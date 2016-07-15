require "array_model/version"

#
# ArrayModel
#
# This is used as a base class to create ActiveRecord / Sequel style models from
# simple arrays and hashes. This is useful for integrating simple reference data 
# into an ActiveRecord model without having to create many small tables that will never
# change.
#
# The objects that are created are read only by design, as 
#
# Example:
#
# 	USERS = [
# 		{ name: 'Nathan', year: 1984 }, 
# 		{ name: 'Dave', year: 1987 }
# 	]
#
#	class User < ArrayModel
#		model_data USERS
#		attr_value_reader :name
#		attr_value_reader :year
#
#		def age
#			Time.now.year - year
#		end
#	end
#
# 	User[0].age # => 32
# 	User[1].name # => "Dave"
#
class ArrayModel
	def self.[](k)
		if @data.is_a? Array
			item_data = @data[k.to_i] 
		else
			item_data = @data[k] || @data[k.to_sym]
		end

		if item_data.nil?
			return nil
		else
			return self.new(item_data)
		end		
	end

	def self.all
		if @data.is_a? Array
			@data.map { |v| self.new(v) }
		elsif @data.is_a? Hash
			@data.map { |k, v| self.new(v) }
		else
			raise "ArrayModel does not support #{@data.class} as data source"
		end		
	end

	def values
		@item_data
	end

	def initialize(item_data)
		item_data.is_a! Hash, 'item_data'
		@item_data = item_data
	end

	def self.attr_value_reader(name, options = {})
		define_method name.to_sym do
			values[(options[:key] || name).to_sym]
		end
	end

	def self.model_data(data)
		@data = data	
	end
end
