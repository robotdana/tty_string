# TTYString

[![Build Status](https://travis-ci.org/robotdana/tty_string.svg?branch=master)](https://travis-ci.org/robotdana/tty_string)

Render a string like your terminal does by parsing ANSI TTY codes.
This is useful for testing CLI's

Supported codes

 - `\b`
 - `\e[A`
 - `\e[B`
 - `\e[C`
 - `\e[D`
 - `\e[E`
 - `\e[F`
 - `\e[G`
 - `\e[H`
 - `\e[J`
 - `\e[K`
 - `\e[f`
 - `\e[m`
 - `\n`
 - `\r`
 - `\t`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty_string'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty_string

## Usage

```ruby
TTYString.new("th\ta string\e[3Gis is").to_s
=> "this is a string"
```

Styling information is suppressed by default:
```ruby
TTYString.new("th\ta \e[31mstring\e[0m\e[3Gis is").to_s
=> "this is a string"
```
But can be passed through:
```ruby
TTYString.new("th\ta \e[31mstring\e[0m\e[3Gis is", clear_style: false).to_s
=> "this is a \e[31mstring\e[0m"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/tty_string.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
