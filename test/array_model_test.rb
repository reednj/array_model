require 'array_model'
require 'minitest/autorun'

USER_DATA = [
	{ :username => 'reednj', :name => 'Nathan', :age => 31 },
	{ :username => 'dmate', :name => 'Dave', :age => 29 },
	{ :username => 'rkon', :name => 'Rachel', :age => 25 },
	{ :username => 'zhena', :name => 'Lucy', :age => 19 },
	{ :username => 'j77', :name => 'Peter', :age => 16 }
]

class Users < ArrayModel
	model_data USER_DATA
	attr_value_reader :username
	attr_value_reader :age

	def adult?
		self.age >= 18
	end
end

class KeyUsers < ArrayModel
	model_data USER_DATA, :key => :username
	attr_value_reader :username
	attr_value_reader :age
end

class ArrayModelTest < Minitest::Test
	def test_can_select_by_index
		assert USER_DATA.first == Users.all.first.values, 'first item does not match'
		assert USER_DATA[1] == Users[1].values, 'second item does not match'
	end

	def test_can_access_attributes_by_name
		u = Users.all.first
		assert u.username.is_a?(String), 'could not get value from model instance'
		assert u.username == u[:username], 'subscript does not match method value'
		assert u.username == USER_DATA[0][:username], 'field value does not match'
	end

	def test_extension_methods_work
		u = Users.all.select{|u| u.username == 'j77' }.first
		assert u.adult? == u.age >= 18, 'extension method gave unexpected result'

		u = Users.all.first
		assert u.adult? == u.age >= 18, 'extension method gave unexpected result'
	end

	def test_index_by_key_works
		username = 'rkon'
		u = KeyUsers['rkon']
		t = USER_DATA.select{|a| a[:username] == username }.first

		assert !u.nil?, 'expected record, but got nil'
		assert u.username == t[:username], 'incorrect record selected, field does not match'
		assert KeyUsers['randommm'].nil?, 'non-existant key should return nil'
		assert KeyUsers[0].nil?, 'non-existant integer key should return nil'
	end

end
