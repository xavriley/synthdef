require "synthdef/version"
require 'bindata'

class PascalString < BinData::Primitive
  uint8  :len,  :value => lambda { data.length }
  string :data, :read_length => :len

  def get;   self.data; end
  def set(v) self.data = v; end
end

class Synthdef < BinData::Record
  def check_version
    # Returns zero based index for choices
    file_version == 1 ? 0 : 1
  end

  endian :big

  string :file_type_id, read_length: 4
  int32 :file_version
  int16 :no_of_synthdefs

  array :synthdefs, initial_length: lambda { no_of_synthdefs } do
    pascal_string :name

    choice        :no_of_constants, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
    array         :constants, initial_length: lambda { no_of_constants } do
      float :constant
    end

    choice        :no_of_params, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
    array        :params, initial_length: lambda { no_of_params } do
      float :initial_parameter_value
    end

    choice        :no_of_param_names, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
    array        :param_names, initial_length: lambda { no_of_param_names } do
      pascal_string :param_name
      choice        :param_index, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
    end

    choice        :no_of_ugens, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
    array        :ugens, initial_length: lambda { no_of_ugens } do
      pascal_string :ugen_name
      int8          :rate
      choice        :no_of_inputs, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
      choice        :no_of_outputs, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
      int16         :special, initial_value: 0
      array         :inputs, initial_length: lambda { no_of_inputs } do
        choice :src, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
        if lambda { src == -1 }
          choice :input_constant_index, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
        else
          choice :input_ugen_index, :selection => :check_version, :choices => {0 => :int16, 1 => :int32}
        end
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
