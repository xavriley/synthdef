require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/dot'

require "synthdef/version"
require "synthdef/graphviz"
require "synthdef/parser"

class Synthdef

  def self.read(*args)
    Parser.read(*args)
  end

  def self.has_params?(sdef, param_list)
    sdef = sdef.snapshot # ensure we cast to Ruby types, not bindata types
    param_list.map!(&:to_s)

    sdef[:synthdefs].all? {|s|
      # check using intersection of arrays
      (s[:param_names].map {|pn| pn[:param_name] } & param_list) == param_list
    }
	end

end
