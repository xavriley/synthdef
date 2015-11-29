# Synthdef

## pre-Alpha

A gem to work with SuperCollider's binary synthdef format. This uses the excellent [`bindata`](https://github.com/dmendel/bindata) gem to define the spec in a very readable way. The implementation is around than 60 lines of code.

It works with both SynthDef and SynthDef2 formats.

I found the actual spec here:

[http://doc.sccode.org/Reference/Synth-Definition-File-Format.html](http://doc.sccode.org/Reference/Synth-Definition-File-Format.html)

Before I found the spec(!), inspiration was taken from the following links:

- [Clojure - Overtone - synthdef.clj](https://github.com/overtone/overtone/blob/master/src/overtone/sc/machinery/synthdef.clj)

This handles the synthdef format in Overtone, using Jeff Rose's [byte-spec](https://github.com/overtone/byte-spec) library.

- [Haskell - synthdef.ipynb](https://gist.github.com/miguel-negrao/8d71807afb513412d780)

Code by @miguel-negrao to parse synthdefs in Haskell.

Other libraries and langs I haven't checked out yet:

- [Go - scgolang](https://github.com/scgolang/sc/blob/master/synthdef.go)

## Installation

Add this line to your application's Gemfile:

    gem 'synthdef'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synthdef

## Command line usage

The gem ships with a command line tool to print the contents of a synthdef file as json

```
$ gem install synthdef
$ synthdef /path/to/synthdefs/foo.scsyndef
=> {
  "file_type_id": "SCgf",
  "file_version": 1,
  "no_of_synthdefs": 1,
  "synthdefs": [
    {
      "name": "sonic-pi-pretty_bell",
      "no_of_constants": 15,
      "constants": [
        0.0,
        ...
```

## Usage

Take a binary scsyndef file (you can find an example in `spec/data/recorder.scsyndef`)

```
$ bundle exec irb

# pp is just to pretty print the output, not essential
>> require 'pp'
=> true
>> require 'synthdef'
=> true
>> raw = open("spec/data/recorder.scsyndef").read
>> pp Synthdef.read(raw)
=> {:file_type_id=>"SCgf",
 :file_version=>1,
 :no_of_synthdefs=>1,
 :synthdefs=>
  [{:name=>"sonic-pi-recorder",
    :no_of_constants=>0,
    :constants=>[],
    :no_of_params=>2,
    :params=>[0.0, 0.0],
    :no_of_param_names=>2,
    :param_names=>
     [{:param_name=>"out-buf", :param_index=>0},
      {:param_name=>"in_bus", :param_index=>1}],
    :no_of_ugens=>3,
    :ugens=>
     [{:ugen_name=>"Control",
       :rate=>1,
       :no_of_inputs=>0,
       :no_of_outputs=>2,
       :special=>0,
       :inputs=>[],
       :outputs=>[1, 1]},
      {:ugen_name=>"In",
       :rate=>2,
       :no_of_inputs=>1,
       :no_of_outputs=>2,
       :special=>0,
       :inputs=>[{:src=>0, :input_constant_index=>1}],
       :outputs=>[2, 2]},
      {:ugen_name=>"DiskOut",
       :rate=>2,
       :no_of_inputs=>3,
       :no_of_outputs=>1,
       :special=>0,
       :inputs=>
        [{:src=>0, :input_constant_index=>0},
         {:src=>1, :input_constant_index=>0},
         {:src=>1, :input_constant_index=>1}],
       :outputs=>[2]}],
    :no_of_variants=>0,
    :variants=>[]}]}
```

## Differences between SynthDef versions 1 and 2

```
# Taken from spec
# synth-definition-file for version 2

int32 - four byte file type id containing the ASCII characters: "SCgf"
int32 - file version, currently 2.
int16 - number of synth definitions in this file (D).
[ synth-definition ] * D
pstring - the name of the synth definition
int32 - number of constants (K)
[float32] * K - constant values
int32 - number of parameters (P)
[float32] * P - initial parameter values
int32 - number of parameter names (N)
[ param-name ] * N
pstring - the name of the parameter
int32 - its index in the parameter array
int32 - number of unit generators (U)
[ ugen-spec ] * U
pstring - the name of the SC unit generator class
int8 - calculation rate
int32 - number of inputs (I)
int32 - number of outputs (O)
int16 - special index
[ input-spec ] * I
int32 - index of unit generator or -1 for a constant
if (unit generator index == -1)
int32 - index of constant
else
int32 - index of unit generator output
[ output-spec ] * O
int8 - calculation rate
int16 - number of variants (V)
[ variant-spec ] * V
pstring - the name of the variant
[float32] * P - variant initial parameter values
```

Again, taken from the spec

```
The original SynthDef format differs in that the following items are int16 instead of int32.
NOTE: The following list describes what has changed between SynthDef and SynthDef2. It is not a complete description of the the original SynthDef file format.
int32 - file version, currently 1. (This is 2 for the new format.)
a synth-definition is :
int16 - number of constants (K)
int16 - number of parameters (P)
int16 - number of parameter names (N)
int16 - number of unit generators (U)
a param-name is :
int16 - its index in the parameter array
a ugen-spec is :
int16 - number of inputs (I)
int16 - number of outputs (O)
an input-spec is :
int16 - index of unit generator or -1 for a constant
int16 - index of constant
int16 - index of unit generator output
```

## Contributing

1. Fork it ( http://github.com/xavriley/synthdef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
