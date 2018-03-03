require 'spec_helper'
require 'active_support'

describe Synthdef do
  let(:synthdef_binary) { IO.read(File.expand_path("../data/recorder.scsyndef", __FILE__)) }
  let(:complex_synthdef_binary) { IO.read(File.expand_path("../data/hoover.scsyndef", __FILE__)) }

  it 'reads a basic version 1 synthdef' do
    parsed_synthdef = Synthdef.read(synthdef_binary).snapshot

    expect(parsed_synthdef).to be_a(Hash)
    expect(parsed_synthdef).not_to be_empty
    expect(parsed_synthdef[:synthdefs].first[:no_of_constants]).to eq(0)
    expect(parsed_synthdef[:synthdefs].first[:no_of_params]).to eq(2)
  end

  it 'reads a complex version 2 synthdef' do
    parsed_synthdef = Synthdef.read(complex_synthdef_binary).snapshot

    expect(parsed_synthdef).to be_a(Hash)
    expect(parsed_synthdef[:file_version]).to eq(2)
    expect(parsed_synthdef[:no_of_synthdefs]).to eq(1)
    expect(parsed_synthdef[:synthdefs].first[:no_of_constants]).to eq(32)
    expect(parsed_synthdef[:synthdefs].first[:constants].last).to eq(0.9056051969528198)
    expect(parsed_synthdef[:synthdefs].first[:no_of_params]).to eq(31)
    expect(parsed_synthdef[:synthdefs].first[:param_names].last).to eq({param_name: "out_bus", param_index: 30})
    expect(parsed_synthdef[:synthdefs].first[:no_of_ugens]).to eq(141)
    expect(parsed_synthdef[:synthdefs].first[:ugens].last[:ugen_name]).to eq("Out")
    expect(parsed_synthdef[:synthdefs].first[:no_of_variants]).to eq(0)
  end

  it 'converts a basic version 1 synthdef to a version 2 synthdef' do
    parsed_synthdef = Synthdef.read(synthdef_binary)
    parsed_synthdef[:file_version] = 2

    converted_synthdef = Synthdef.read(parsed_synthdef.to_binary_s).snapshot
    expect(converted_synthdef).to be_a(Hash)
    expect(converted_synthdef).not_to be_empty
    expect(converted_synthdef[:file_version]).to eq(2)
    expect(converted_synthdef.to_h.except(:file_version)).to eq(parsed_synthdef.snapshot.to_h.except(:file_version))
  end

  it 'checks for a list of required inputs and outputs' do
    parsed_synthdef = Synthdef.read(complex_synthdef_binary)
    required_params = [:note, :out_bus]

    expect(Synthdef.has_params?(parsed_synthdef, required_params)).to be true
  end

  it 'can identify param groups like slideable' do
    # identify a param by name
    # check if it's already slideable
    # add slide params in if not EnvGen with default args
    # need to also specify arg limits

    parsed_synthdef = Synthdef.read(complex_synthdef_binary).snapshot.synthdefs.first

    acc = {:slideable => [], :non_slideable => []}

    slideable_params = parsed_synthdef[:param_names].select {|x|
      x[:param_name][/_slide\Z|_slide_shape\Z|_slide_curve\Z/]
    }

    slideable_param_base_names = slideable_params.map {|x|
      x[:param_name].gsub(/_slide\Z|_slide_shape\Z|_slide_curve\Z/, '')
    }.uniq

    slideable_and_non_slideable_params = parsed_synthdef[:param_names].inject(acc) {|x|
      x[:param_name][/_slide\Z|_slide_shape\Z|_slide_curve\Z/]
    }
  end

  it 'can rename output buses'

  it 'produces a dot file for a graph' do
    parsed_synthdef = Synthdef.read(IO.read "/Users/xriley/Downloads/sonic-pi-fx_echo.scsyndef").snapshot.synthdefs.first
    parsed_synthdef[:ugens].map!.with_index {|u,i|
      u.merge(ugen_index: i, ugen_id: "#{i}#{u[:ugen_name]}")
    }

    # initialize graph
    nrg = RGL::DirectedAdjacencyGraph.new.to_dot_graph

    # need to expand out Control Ugen using param_names and params and add these as nodes
    control_ugens = parsed_synthdef[:param_names].map {|x| x.merge(param_default_value: parsed_synthdef[:params][x[:param_index]]) }
    control_ugens.each {|ctl_ugen| nrg << RGL::DOT::Node.new("name" => ctl_ugen[:param_name],
                                                             "label" => ctl_ugen[:param_name].to_s,
                                                             "shape" => "invhouse",
                                                             "style" => "rounded, filled, bold",
                                                             "fillcolor" => "black",
                                                             "fontcolor" => "white") }

    # Again, the Control Ugen is strange because it acts as a placeholder in the graph
    # for the input params. We need to filter it out when linking the reset of
    # the nodes together
    parsed_synthdef[:ugens].select {|x|
      not x[:ugen_name][/Control/]
    }.map! {|ugen|
			# rename UnaryOpUgen and BinaryOpUgen based on lookup
      if ugen[:special] != 0
        case ugen[:ugen_name].to_s
        when "UnaryOpUGen"
					ugen[:label] = Synthdef::UNARY_OPS.invert[ugen[:special]]
				when "BinaryOpUGen"
					ugen[:label] = Synthdef::BINARY_OPS.invert[ugen[:special]]
        end
      else
        ugen[:label] = ugen[:ugen_name].to_s
			end

      ugen
    }

    parsed_synthdef[:ugens].select {|x|
      not x[:ugen_name][/Control/]
    }.each {|ugen|
      begin
        arg_names = IO.read(Pathname.new(File.join(Synthdef::PATH_TO_LOCAL_SUPERCOLLIDER,
                                                   "#{ugen[:ugen_name]}.schelp"))).scan(/argument::(.+)/).flatten
      rescue
        $stderr.puts "Argnames couldn't be retrieved for #{ugen[:ugen_name]}. Have you set a path to your local SuperCollider install?"
      end

      port_edge_pairs = ugen[:inputs].map.with_index {|i, idx|
        port, edge = nil

        if i[:src] == -1
          default_value = parsed_synthdef[:constants][i[:input_constant_index]]
        else
          default_value = nil
        end

        port_name = (arg_names[idx] || "a").to_s.strip
        port = RGL::DOT::Port.new(port_name, [arg_names[idx], default_value].compact.join(" "))

        if parsed_synthdef[:ugens][i[:src]][:ugen_name] =~ /Control/
          from = control_ugens[i[:input_constant_index]][:param_name]
        else
          # the label for nodes will have a <portid>portname combo as the last line
          # we need to make sure that the outputs are always coming from the last port
          # in the node by using ugen_id:label
          from = [parsed_synthdef[:ugens][i[:src]][:ugen_id], parsed_synthdef[:ugens][i[:src]][:label]].join(':')
        end

        if i[:src] != -1
          # if input is not a constant
          edge = RGL::DOT::DirectedEdge.new('from' => from, 'to' => [ugen[:ugen_id], port_name].join(':'))
        end

        [port, edge]
      } # end inputs

      ports = RGL::DOT::Port.new(port_edge_pairs.map {|p,e| p }.compact)
      edges = port_edge_pairs.map {|p,e| e }.compact

      nrg << RGL::DOT::Node.new({"name" => ugen[:ugen_id],
                                 "label" => "{#{ports.to_s} | <#{ugen[:label]}>#{ugen[:label]}}",
                                 "rankdir" => "LR",
                                 "shape" => "record"},
                                 (RGL::DOT::NODE_OPTS << 'rankdir'))
      edges.each do |edge|
        nrg << edge
      end
    }

    File.open('graph.dot', 'w+') {|f| f.write nrg.to_s.gsub(':', '":"') }
    `dot -Tjpg -o graph.jpg graph.dot`
    puts `open graph.jpg`
  end
  it 'renders a pdf of the graph'
  it 'takes configuration from a json file'

  it 'can parse a synthdef that uses all types including variants and initial rate'
end
