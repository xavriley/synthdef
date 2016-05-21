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
    expect(parsed_synthdef[:synthdefs].first[:constants].last).to eq(-4.0)
    expect(parsed_synthdef[:synthdefs].first[:no_of_params]).to eq(5)
    expect(parsed_synthdef[:synthdefs].first[:param_names].last).to eq({param_name: "gate", param_index: 4})
    expect(parsed_synthdef[:synthdefs].first[:no_of_ugens]).to eq(104)
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
end
