# TTYString

[![Build Status](https://travis-ci.com/robotdana/tty_string.svg?branch=main)](https://travis-ci.com/robotdana/tty_string)
[![Gem Version](https://badge.fury.io/rb/tty_string.svg)](https://rubygems.org/gems/tty_string)

Render to a string like your terminal does by (narrowly) parsing ANSI TTY codes.
Intended for use in tests of command line interfaces.

## Features

- supports ruby 2.4 - 3.0.0.preview1, and jruby
- has no dependencies outside ruby stdlib

## Supported codes

| Code | Description | Default |
|------|-------------|---------|
| `\a` | bell: suppressed | |
| `\b` | backspace: clear the character to the left of the cursor and move the cursor back one column | |
| `\n` | newline: move the cursor to the start of the next line | |
| `\r` | return: move the cursor to the start of the current line | |
| `\t` | tab: move the cursor to the next multiple-of-8 column | |
| `\e[nA` | move the cursor up _n_ lines | _n_=`1` |
| `\e[nB` | move the cursor down _n_ lines | _n_=`1` |
| `\e[nC` | move the cursor right _n_ columns | _n_=`1` |
| `\e[nD` | move the cursor left _n_ columns | _n_=`1` |
| `\e[nE` | move the cursor down _n_ lines, and to the start of the line | _n_=`1` |
| `\e[nF` | move the cursor up _n_ lines, and to the start of the line | _n_=`1` |
| `\e[nG` | move the cursor to column _n_. `1` is left-most column | _n_=`1` |
| `\e[n;mH` <br> `\e[n;mf` | move the cursor to row _n_, column _m_. `1;1` is top left corner | _n_=`1` _m_=`1` |
| `\e[nJ` | _n_=`0`: clear the screen from the cursor forward <br>_n_=`1`: clear the screen from the cursor backward <br>_n_=`2` or _n_=`3`: clear the screen | _n_=`0` |
| `\e[nK` | _n_=`0`: clear the line from the cursor forward <br>_n_=`1`: clear the line from the cursor backward <br>_n_=`2`: clear the line | _n_=`0` |
| `\e[nS` | scroll up _n_ rows | _n_=`1` |
| `\e[nT` | scroll down _n_ rows | _n_=`1` |
| `\e[m` | styling codes: optionally suppressed with `clear_style: false` | |

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
["th\ta string\e[3Gis is"].each(&TTYString)
=> ["this is a string"]
```

## Limitations

- Various terminals are wildly variously permissive with what they accept,
  so this doesn't even try to cover all possible cases,
  instead it covers the narrowest possible case, and leaves the codes in place when unrecognized

- `clear_style: false` treats the style codes as regular text which may work differently when rendering codes that move the cursor.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests and linters. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robotdana/tty_string.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
