require "array_model/version"

#
# ArrayModel
#
# This is used as a base class to create ActiveRecord / Sequel style models from
# simple arrays and hashes. This is useful for integrating simple reference data 
# into an ActiveRecord model without having to create many small tables that will never
# change.
#
# This data should be never change while the application is running, so the model objects
# that are created are read only. The data can come either from a constant in the ruby
# script itself, or from the filesystem as a YAML or JSON file.
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
	# get the object with the key :k:
	#
	# By default :k: will be a simple array index, but it can be changed to
	# any field by using the :primary_key option when calling :model_data:
	# when the class is defined
	#
	#		Users['reednj'] # => #<Users:0x007fe693866808>
	#
	def self.[](k)
		if @data_key.nil?
			item_data = @data[k.to_i]
		else
			# if a key has been specified, then find the first matching
			# record. It would be faster to convert it to a hash, but since the
			# number of records should be small, this should do for now
			item_data = @data.select{|a| a[@data_key] == k }.first
		end

		return nil if item_data.nil?
		return self.new(item_data)
	end

	# returns an array of all the data in the model. The array will contain
	# objects of the appropriate type (not raw hashes)
	def self.all
		if @data.is_a? Array
			@all_records ||= @data.map { |v| self.new(v) }
		else
			raise "ArrayModel does not support #{@data.class} as data source"
		end		
	end

	# an alias for the values method to return a raw value from the data
	# hash for a given model object. The attr_reader methods should be 
	# prefered to accessing the hash directly, but this can be useful
	# in certain cases
	#
	#		u = Users['reednj']
	#		u.username 			# => 'reednj'
	#		u.values(:username) # => 'reednj'
	#		u[:username] 		# => 'reednj'
	#
	def [](k)
		values[k]
	end

	# returns the raw Hash that provides the data for the model
	# object
	#
	#		Users['reednj'].values # => {:username => 'reednj', ...}
	#
	def values
		@item_data
	end

	# create a new model object from a given hash. This should never 
	# need to be called directly - the class methods should be used
	# to get model objects from the dataset
	def initialize(item_data)
		item_data.is_a! Hash, 'item_data'
		@item_data = item_data
	end

	# Adds attr_reader methods to the class for a given field
	# in the data hash. The :key: option can be used to set the name
	# of the key in the hash, if it doesn't have the same name as the
	# method
	#
	#		class Users < ArrayModel
	#			...
	#			attr_model_reader :username
	#			attr_model_reader :user_id, :key => :userId
	#			...
	#		end
	#
	def self.attr_model_reader(name, options = {})
		define_method name.to_sym do
			values[(options[:key] || name).to_sym]
		end
	end

	# like :attr_model_reader:, but mulitple readers can be added at
	# once. No options can be passed when using this method to add
	# the readers
	#
	#		class Users < ArrayModel
	#			...
	#			attr_model_readers [:username, :user_id]
	#			...
	#		end
	#
	def self.attr_model_readers(keys)
		keys.each {|k| attr_model_reader k }
	end

	# add the model data to the model class. This data should be
	# in the from of an array of hashes.
	#
	# The array model is designed to handle static reference data, so the data
	# should not change while the application is running. It can come either from
	# a constant hard coded into the ruby file, or from a json or yaml file on
	# the filesystem.
	#
	# The :primary_key option can be used to index the data by a particular field
	# in the hash when it is accessed later via the subscript operator. If this option
	# is ommited then the data will be accessable simply by the array index 
	#
	#		class Users < ArrayModel
	#			# USER_LIST is a const containing an array of hashes
	#			model_data USER_LIST, :primary_key => :username
	#			...
	#		end
	#	
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
