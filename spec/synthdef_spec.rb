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

  it 'can identify param groups like slideable'
  it 'can rename output buses'
  it 'produces a dot file for a graph'
  it 'renders a pdf of the graph'
  it 'takes configuration from a json file'

  it 'can parse a synthdef that uses all types including variants and initial rate'
end
