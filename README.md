# TTYString

[![Build Status](https://travis-ci.com/robotdana/tty_string.svg?branch=master)](https://travis-ci.com/robotdana/tty_string)
[![Gem Version](https://badge.fury.io/rb/tty_string.svg)](https://rubygems.org/gems/tty_string)

Render to a string like your terminal does by (narrowly) parsing ANSI TTY codes.

## Features

- supports ruby 2.4 - 2.7, and jruby
- has no dependencies outside ruby stdlib

## Supported codes

 - `\a` # BEL, just removed.
 - `\b` # backspace
 - `\n` # newline
 - `\r` # return, jump to the start of the line
 - `\t` # tab, move to the next multiple-of-8 column
 - `\e[nA` # move up n lines, default: 1
 - `\e[nB` # move down n lines, default: 1
 - `\e[nC` # move right n columns, default: 1
 - `\e[nD` # move left n columns, default: 1
 - `\e[nE` # move down n lines, and to the start of the line, default: 1
 - `\e[nF` # move up n lines, and to the start of the line, default: 1
 - `\e[nG` # jump to column to n
 - `\e[n;mH` # jump to row n, column m, default: 1,1
 - `\e[nJ` # n=0: clear the screen forward, n=1: clear backward, n=2 or 3: clear the screen. default 0
 - `\e[nK` # n=0: clear the line forward, n=1: clear the line backward, n=2: clear the line. default 0
 - `\e[n;mf` # jump to row n, column m, default: 1,1
 - `\e[m` # styling codes, optionally suppressed with `clear_style: false`
 - `\e[nS` # scroll down n rows, default 1
 - `\e[nT` # scroll up n rows, default 1

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty_string', '~> 1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty_string

## Usage

```ruby
TTYString.parse("th\ta string\e[3Gis is")
=> "this is a string"
```

Styling information is suppressed by default:
```ruby
TTYString.parse("th\ta \e[31mstring\e[0m\e[3Gis is")
=> "this is a string"
```
But can be passed through:
```ruby
TTYString.parse("th\ta \e[31mstring\e[0m\e[3Gis is", clear_style: false)
=> "this is a \e[31mstring\e[0m"
```

Just for fun TTYString.to_proc provides the `parse` method as a lambda, so:
```ruby
"th\ta string\e[3Gis is".yield_self(&TTYString)
=> "this is a string"
```

## Limitations

Various terminals are wildly variously permissive with what they accept,
so this doesn't even try to cover all possible cases,
instead it covers the narrowest possible case, and leaves the codes in place when unrecognized

`clear_style: false` treats the style codes as regular text which may work differently when rendering codes that move the cursor.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests and linters. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/tty_string.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
