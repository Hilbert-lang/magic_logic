# MagicLogic

```rb
p = P["If it's raining then it's cloudy."]
q = P["It's raining."]
r = P["It's cloudy."]

~(~p) >= p
# =>TRUE

(p * (p >= q)) >= q
# =>TRUE

((p >= q) * (q >= r)) >= (p >= r)
# =>TRUE


(~p * (p + q)) >= (q)
# =>TRUE


((p >= q) * (q >= r) * p) >= (r)
# =>TRUE

(p * ~p) >= r
# =>TRUE
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'magic_logic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magic_logic

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/magic_logic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
