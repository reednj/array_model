# ArrayModel

ArrayModel is a class to create ActiveRecord / Sequel style models from simple arrays and hashes. This is useful for integrating simple reference data into an application without having to create many small tables that will never change.

As data should be never change while the application is running, the model objects that are created are read only. The data can come either from a constant in the ruby script itself, or from the filesystem as a YAML or JSON file.

## Usage

Example:

    USERS = [
        { name: 'Nathan', year: 1984 }, 
        { name: 'Dave', year: 1987 }
    ]

    class User < ArrayModel
        model_data USERS
        attr_model_reader :name
        attr_model_reader :year

        def age
            Time.now.year - year
        end
    end

    User[0].age # => 32
    User[1].name # => "Dave"