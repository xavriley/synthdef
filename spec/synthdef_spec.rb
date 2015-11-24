require 'spec_helper'

describe Synthdef do
  let(:synthdef_binary) { IO.read(File.expand_path("../data/recorder.scsyndef", __FILE__)) }

  it 'reads a basic synthdef' do
    parsed_synthdef = Synthdef.read(synthdef_binary).snapshot

    expect(parsed_synthdef).to be_a(Hash)
    expect(parsed_synthdef).not_to be_empty
  end
end
