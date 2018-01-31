require 'bindata'

class PascalString < BinData::Primitive
  uint8  :len,  :value => lambda { data.length }
  string :data, :read_length => :len

  def get;   self.data; end
  def set(v) self.data = v; end
end

class SynthInt < BinData::Choice
  endian :big
  default_parameter :selection => :check_version
  default_parameter :copy_on_change => true

  int16 0
  int32 1
end

class Synthdef::Parser < BinData::Record

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

    synth_int     :no_of_constants
    array         :constants, initial_length: lambda { no_of_constants } do
      float :constant
    end

    synth_int    :no_of_params
    array        :params, initial_length: lambda { no_of_params } do
      float :initial_parameter_value
    end

    synth_int    :no_of_param_names
    array        :param_names, initial_length: lambda { no_of_param_names } do
      pascal_string :param_name
      synth_int    :param_index
    end

    synth_int    :no_of_ugens
    array        :ugens, initial_length: lambda { no_of_ugens } do
      pascal_string :ugen_name
      int8          :rate
      synth_int     :no_of_inputs
      synth_int     :no_of_outputs
      int16         :special, initial_value: 0
      array         :inputs, initial_length: lambda { no_of_inputs } do
        synth_int  :src
        if lambda { src == -1 }
          synth_int :input_constant_index
        else
          synth_int :input_ugen_index
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
