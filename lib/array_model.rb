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
#		attr_model_reader :name
#		attr_model_reader :year
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
		if @data_key.nil?
			item_data = @data[k.to_i]
		else
			item_data = @data.select{|a| a[@data_key] == k }.first
		end

		return nil if item_data.nil?
		return self.new(item_data)
	end

	def self.all
		if @data.is_a? Array
			@all_records ||= @data.map { |v| self.new(v) }
		else
			raise "ArrayModel does not support #{@data.class} as data source"
		end		
	end

	def [](k)
		values[k]
	end

	def values
		@item_data
	end

	def initialize(item_data)
		item_data.is_a! Hash, 'item_data'
		@item_data = item_data
	end

	def self.attr_model_reader(name, options = {})
		define_method name.to_sym do
			values[(options[:key] || name).to_sym]
		end
	end

	def self.attr_model_readers(keys)
		keys.each {|k| attr_model_reader k }
	end

	def self.model_data(data, options = nil)
		options ||= {}
		data.is_a! Array, 'data'

		@data_key = options[:primary_key]
		@data = data	
	end
end

class Object
	def is_a!(t, name = nil)
		if !is_a? t
			if name.nil?
				raise "expected #{t} but got #{self.class}"
			else
				raise "#{name} requires #{t} but got #{self.class}"
			end
		end
	end
end
