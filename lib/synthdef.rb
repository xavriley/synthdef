require "synthdef/version"
require 'bindata'

class PascalString < BinData::Primitive
  uint8  :len,  :value => lambda { data.length }
  string :data, :read_length => :len

  def get;   self.data; end
  def set(v) self.data = v; end
end

class Synthdef < BinData::Record
  endian :big

  string :file_type_id, read_length: 4
  uint32 :file_version
  uint16 :no_of_synthdefs

  array :synthdefs, initial_length: lambda { no_of_synthdefs } do
    pascal_string :name

    int16        :no_of_constants
    array        :constants, initial_length: lambda { no_of_constants } do
      float :constant
    end

    int16        :no_of_params
    array        :params, initial_length: lambda { no_of_params } do
      float :initial_parameter_value
    end

    int16        :no_of_param_names
    array        :param_names, initial_length: lambda { no_of_param_names } do
      pascal_string :param_name
      int16         :param_index
    end

    int16        :no_of_ugens
    array        :ugens, initial_length: lambda { no_of_ugens } do
      pascal_string :ugen_name
      int8          :rate
      int16         :no_of_inputs
      int16         :no_of_outputs
      int16         :special, initial_value: 0
      array         :inputs, initial_length: lambda { no_of_inputs } do
        int16 :src
        int16 :input_index
      end
      array         :outputs, initial_length: lambda { no_of_outputs } do
        int8 :calculation_rate
      end
    end

    int16 :no_of_variants, initial_value: 0
    array :variants, initial_length: lambda { no_of_variants } do
      pascal_string :variant_name
      float         :variant_param
    end
  end

end
