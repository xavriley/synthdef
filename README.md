# Synthdef

## pre-Alpha

A gem to work with SuperCollider's binary synthdef format. This uses the excellent [`bindata`](https://github.com/dmendel/bindata) gem to define the spec in a very readable way. The implementation is less than 60 lines of code.

Inspiration for the spec was taken from the following links:

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

## Usage

Take a binary scsyndef file (you can find an example in `spec/data/recorder.scsyndef`)

```
$ bundle exec irb

>> require 'synthdef'
=> true
>> raw = open("spec/data/recorder.scsyndef").read
>> Synthdef.read(raw)
=> {:file_type_id=>"SCgf", :file_version=>1, :no_of_synthdefs=>1, :synthdefs=>[{:name=>"sonic-pi-recorder", :no_of_constants=>0, :constants=>[], :no_of_params=>2, :params=>[0.0, 0.0], :no_of_param_names=>2, :param_names=>[{:param_name=>"out-buf", :param_index=>0}, {:param_name=>"in_bus", :param_index=>1}], :no_of_ugens=>3, :ugens=>[{:ugen_name=>"Control", :rate=>1, :no_of_inputs=>0, :no_of_outputs=>2, :special=>0, :inputs=>[], :outputs=>[1, 1]}, {:ugen_name=>"InFeedback", :rate=>2, :no_of_inputs=>1, :no_of_outputs=>2, :special=>0, :inputs=>[{:src=>0, :input_index=>1}], :outputs=>[2, 2]}, {:ugen_name=>"DiskOut", :rate=>2, :no_of_inputs=>3, :no_of_outputs=>1, :special=>0, :inputs=>[{:src=>0, :input_index=>0}, {:src=>1, :input_index=>0}, {:src=>1, :input_index=>1}], :outputs=>[2]}], :no_of_variants=>0, :variants=>[]}]}
```

## Contributing

1. Fork it ( http://github.com/xavriley/synthdef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
