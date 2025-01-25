# frozen_string_literal: true

RSpec::Matchers.define :render_as do |expected|
  match do |actual|
    @actual = described_class.parse(actual)
    expect(@actual).to eq expected
  end
end

RSpec::Matchers.define :render_with_style_as do |expected|
  match do |actual|
    @actual = described_class.parse(actual, style: described_class::RENDER)
    expect(@actual).to eq expected
  end
end

RSpec.describe TTYString do
  describe '.to_proc' do
    it "can call to_proc. why? don't ask questions" do
      expect(["ab\bc"].map(&described_class)).to eq ['ac']
    end
  end

  describe '.parse' do
    it 'raises with unexpected style arg' do
      expect { described_class.parse('', style: :nonsense) }
        .to raise_error ArgumentError, '`style:` must be either TTYString::RENDER or TTYString::DROP (default)'
    end

    it 'raises with unexpected unknown arg' do
      expect { described_class.parse('', unknown: :nonsense) }
        .to raise_error ArgumentError, '`unknown:` must be either TTYString::RAISE or TTYString::DROP (default)'
    end

    it 'can render an empty string' do
      expect('').to render_as ''
    end

    it 'can render a string with no formatting information' do
      expect('a string').to render_as 'a string'
    end

    describe '\a' do
      it 'drops \a' do
        expect("ab\ac").to render_as 'abc'
      end
    end

    describe '\b' do
      it 'backspaces when it meets a \b' do
        expect("ab\bc").to render_as 'ac'
      end

      it "doesn't backspace when it meets a \b at the beginning of the line" do
        expect("\bab").to render_as 'ab'
      end

      it "doesn't backspace up a line" do
        expect("ab\n\bcd").to render_as "ab\ncd"
      end
    end

    describe '\r' do
      it 'moves the cursor to the start of the line without changing content' do
        expect("ab\rc").to render_as 'cb'
      end

      it 'with \n, looks the same as \n alone' do
        expect("ab\r\ncd").to render_as "ab\ncd"
      end
    end

    describe '\n' do
      it 'creates a newline. you know this one' do
        expect("ab\ncd").to render_as "ab\ncd"
      end

      it 'preserves a trailing newline.' do
        expect("abcd\n").to render_as "abcd\n"
      end
    end

    describe '\t' do
      it 'advances the cursor up to 8 spaces' do
        expect("\ta").to render_as '        a'
      end

      it 'is backspaced a single space at a time' do
        expect("\t\ba").to render_as '       a'
      end

      it 'counts initial characters toward the 8 spaces' do
        expect("a\tb").to render_as 'a       b'
      end

      it 'counts initial characters beyond the first 8' do
        expect("abcdefghij\tk").to render_as 'abcdefghij      k'
      end

      it 'leaves existing characters unchanged' do
        expect("abc\r\tk").to render_as 'abc     k'
      end
    end

    describe '\e[' do
      describe 'A' do
        it 'moves the cursor up a line' do
          expect("abc\nd\e[Ae").to render_as "aec\nd"
        end

        it 'moves the cursor up a line with arg 1' do
          expect("abc\nd\e[1Ae").to render_as "aec\nd"
        end

        it 'moves the cursor up n lines with arg n' do
          expect("abc\n\n\nd\e[2Ae").to render_as "abc\n e\n\nd"
        end

        it 'does nothing at the edge' do
          expect("abc\e[Ad").to render_as 'abcd'
        end

        it 'drops non-number args' do
          expect("a\e[>Ab").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Ab", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>A"'
        end
      end

      describe 'B' do
        it 'moves the cursor down' do
          expect("a\e[Bb").to render_as "a\n b"
        end

        it 'moves the cursor down n lines' do
          expect("a\e[3Bb").to render_as "a\n\n\n b"
        end

        it 'drops non-number args' do
          expect("a\e[>Bb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Bb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>B"'
        end
      end

      describe 'C' do
        it 'moves the cursor forward' do
          expect("a\e[Cb").to render_as 'a b'
        end

        it 'moves the cursor forward n characters' do
          expect("a\e[3Cb").to render_as 'a   b'
        end

        it 'drops non-number args' do
          expect("a\e[>Cb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Cb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>C"'
        end
      end

      describe 'D' do
        it 'moves the cursor back' do
          expect("abc\e[Dd").to render_as 'abd'
        end

        it 'does nothing at the screen edge' do
          expect("\e[Da").to render_as 'a'
        end

        it 'moves the cursor back n characters' do
          expect("abcdefg\e[3Dh").to render_as 'abcdhfg'
        end

        it 'drops non-number args' do
          expect("a\e[>Db").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Db", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>D"'
        end
      end

      describe 'E' do
        it 'moves the cursor to the beginning of the line 1 line down' do
          expect("abcd\e[2D\e[Efg").to render_as "abcd\nfg"
        end

        it 'moves the cursor to the beginning of the line n lines down' do
          expect("abcd\e[2D\e[2Efg").to render_as "abcd\n\nfg"
        end

        it 'drops non-number args' do
          expect("a\e[>Eb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Eb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>E"'
        end
      end

      describe 'F' do
        it 'moves the cursor to the beginning of the line 1 line p' do
          expect("abcd\nef\e[Fgh").to render_as "ghcd\nef"
        end

        it 'moves the cursor to the beginning of the line n lines up' do
          expect("abcd\n\n\nef\e[2Fgh").to render_as "abcd\ngh\n\nef"
        end

        it 'drops non-number args' do
          expect("a\e[>Fb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Fb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>F"'
        end
      end

      describe 'G' do
        it 'moves the cursor to that column' do
          expect("abc\e[2Gd").to render_as 'adc'
        end

        it 'defaults to 1' do
          expect("abc\e[Gd").to render_as 'dbc'
        end

        it 'drops non-number args' do
          expect("a\e[>Gb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Gb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>G"'
        end
      end

      describe 'H' do
        it 'moves the cursor to that row and column' do
          expect("abc\ndef\e[2;2HE").to render_as "abc\ndEf"
        end

        it 'defaults to 1 1' do
          expect("abc\ndef\e[HA").to render_as "Abc\ndef"
          expect("abc\ndef\e[;HA").to render_as "Abc\ndef"
        end

        it 'defaults to 1 for when only 1 argument used' do
          expect("abc\ndef\e[;2HB").to render_as "aBc\ndef"
          expect("abc\ndef\e[2;HD").to render_as "abc\nDef"
          expect("abc\ndef\e[2HD").to render_as "abc\nDef"
        end

        it 'drops non-number args' do
          expect("a\e[>;2Hb").to render_as 'ab'
          expect("a\e[2;>Hb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>;2Hb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>;2H"'
        end
      end

      describe 'J' do
        it 'deletes from cursor to end of screen if n is 0' do
          expect("abc\ndef\nghi\e[2;2H\e[0J").to render_as "abc\nd"
        end

        it 'deletes from cursor to end of screen if n is missing' do
          expect("abc\ndef\nghi\e[2;2H\e[J").to render_as "abc\nd"
        end

        it 'deletes from cursor to beginning of screen if n is 1' do
          expect("abc\ndef\nghi\e[2;2H\e[1J").to render_as "\n  f\nghi"
        end

        it 'deletes entire screen if n is 2 or 3' do
          expect("abc\ndef\nghi\e[2;2H\e[2J").to render_as ''
          expect("abc\ndef\nghi\e[2;2H\e[3J").to render_as ''
        end

        it 'raises when given unrecognized arguments' do
          expect { described_class.parse("abc\ndef\nghi\e[2;2H\e[4J", unknown: :raise) }
            .to raise_error(described_class::UnknownCodeError, 'Unknown code "\e[4J"')
        end
      end

      describe 'K' do
        it 'deletes the cursor forward' do
          expect("abc\r\e[Kd").to render_as 'd'
        end

        it 'deletes the cursor forward with arg 0' do
          expect("abc\r\e[0Kd").to render_as 'd'
        end

        it 'deletes the cursor backward with arg 1' do
          expect("abc\e[1Kd").to render_as '   d'
        end

        it 'clears the line with arg 2' do
          expect("abcd\e[2K").to render_as ''
        end

        it 'raises when given unrecognized arguments' do
          expect { described_class.parse("abc\ndef\nghi\e[2;2H\e[3K", unknown: :raise) }
            .to raise_error(described_class::UnknownCodeError, 'Unknown code "\e[3K"')
        end
      end

      describe 'f' do
        it 'moves the cursor to that row and column' do
          expect("abc\ndef\e[2;2fE").to render_as "abc\ndEf"
        end

        it 'defaults to 1 1' do
          expect("abc\ndef\e[fA").to render_as "Abc\ndef"
          expect("abc\ndef\e[;fA").to render_as "Abc\ndef"
        end

        it 'defaults to 1 for when only 1 argument used' do
          expect("abc\ndef\e[;2fB").to render_as "aBc\ndef"
          expect("abc\ndef\e[2;fD").to render_as "abc\nDef"
        end
      end

      describe 'm' do
        it 'strips style codes' do
          expect("\e[31mred\e[0m plain").to render_as 'red plain'
        end

        it 'strips style codes with however many ;' do
          expect("\e[31mred\e[36;37;38;2;0;0;0m plain").to render_as 'red plain'
        end

        it 'renders simple color codes' do
          expect("\e[31mred\e[0m plain")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'renders all known style codes, drops the others' do # rubocop:disable RSpec/ExampleLength
          unknown_style_codes = ['38', '48', *('56'..'58'), *('66'..'72'), *('76'..'89'), *('98'..'99')]
          unknown_style_codes.each do |style_code|
            expect("\e[#{style_code}m unstyled")
              .to render_with_style_as ' unstyled'
          end

          (('1'..'107').to_a - unknown_style_codes).each do |style_code|
            expect("\e[#{style_code}m styled")
              .to render_with_style_as "\e[#{style_code}m styled"
          end
        end

        it 'drops an initial reset' do
          expect("\e[0m\run\e[2mstyled")
            .to render_with_style_as "un\e[2mstyled"
        end

        it 'groups style rules' do
          expect("\e[1m\run\e[2m\rstyled")
            .to render_with_style_as "\e[1;2mstyled"
        end

        it 'groups style rules with the last rule last' do
          expect("\e[2;1m\run\e[2m\rstyled")
            .to render_with_style_as "\e[1;2mstyled"
        end

        it 'removes unnecessary color codes set to the same thing' do
          expect("\e[31m\e[31m\e[31m\e[31m\e[31m\e[31mred\e[0m plain")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'removes unnecessary color codes set to the same thing with characters between' do
          expect("\e[31mr\e[31me\e[31md\e[0m plain")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'removes unnecessary color codes set to the same thing with cursor movement' do
          expect(" \e[31med\e[0m plain\r\e[31mr\e[0m")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'removes unnecessary reset codes' do
          expect("\e[31mred\e[0m\e[32m green\e[0m \e[0m")
            .to render_with_style_as "\e[31mred\e[32m green\e[0m "
        end

        it 'removes unnecessary color code overriding previous ones' do
          expect("\e[30m\e[31m\e[32m\e[33m\e[34m\e[31mred\e[0m plain")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'renders the end of the string with the last written color code' do
          expect("      plain\e[31m\e[10D.red")
            .to render_with_style_as " \e[31m.red\e[0m plain\e[31m"
        end

        it 'assumes the string begins reset' do
          expect("     \e[31mred \r\e[0mplain")
            .to render_with_style_as "plain\e[31mred \e[0m"
        end

        it 'renders 24bit color codes' do
          expect("\e[31m\e[38;2;0;0;0m black")
            .to render_with_style_as "\e[38;2;0;0;0m black"
        end

        it 'renders 8bit color codes' do
          expect("\e[31m\e[38;5;0m black")
            .to render_with_style_as "\e[38;5;0m black"
        end

        it 'renders 24bit background codes' do
          expect("\e[41m\e[48;2;0;0;0m black")
            .to render_with_style_as "\e[48;2;0;0;0m black"
        end

        it 'renders 8bit background codes' do
          expect("\e[41m\e[48;5;0m black")
            .to render_with_style_as "\e[48;5;0m black"
        end

        it 'renders 24bit underline codes' do
          expect("\e[59m\e[58;2;0;0;0m black")
            .to render_with_style_as "\e[58;2;0;0;0m black"
        end

        it 'renders 8bit underline codes' do
          expect("\e[59m\e[58;5;0m black")
            .to render_with_style_as "\e[58;5;0m black"
        end

        it 'raises for unknown color code mode' do # rubocop:disable RSpec/ExampleLength
          expect do
            described_class.parse(
              "\e[31m\e[38;1;0m black",
              style: described_class::RENDER,
              unknown: described_class::RAISE
            )
          end.to raise_error described_class::UnknownCodeError, 'Unknown style code "1" in "\e[38;1;0m"'
        end

        it 'raises for unknown 8bit color code value' do # rubocop:disable RSpec/ExampleLength
          expect do
            described_class.parse(
              "\e[31m\e[38;5;?m black",
              style: described_class::RENDER,
              unknown: described_class::RAISE
            )
          end.to raise_error described_class::UnknownCodeError, 'Unknown style code "?" in "\e[38;5;?m"'
        end

        it 'raises for large 8bit color code value' do
          expect do
            described_class.parse("\e[31m\e[38;5;256m black",
                                  style: described_class::RENDER,
                                  unknown: described_class::RAISE)
          end.to raise_error described_class::UnknownCodeError, 'Unknown style code "256" in "\e[38;5;256m"'
        end

        it 'puts the newline in the right place' do
          expect("dog \e[1;31mcat\e[0m\n").to render_with_style_as(
            "dog \e[1;31mcat\e[0m\n"
          )
        end

        it 'fills clears with styled spaces' do
          expect("abcd\033[2D\033[41m\033[1K\033[0m").to render_with_style_as(
            "\e[41m   \e[0md"
          )
        end
      end

      describe 'h' do
        it 'strips bracketed paste mode noise without raising' do
          expect(described_class.parse("\e[?2004h\e[200~echo 'hello'\n\e[201~\e[?2004l", unknown: :raise))
            .to render_as "echo 'hello'\n"
        end

        it 'strips cursor show noise' do
          expect(described_class.parse("b\e[?25had", unknown: :raise))
            .to eq 'bad'
        end

        it 'strips whatever ?1h does' do
          expect("b\e[?1had")
            .to render_as 'bad'
        end

        it 'raises when raising for whatever ?1h is' do
          expect { described_class.parse("b\e[?1had", unknown: :raise) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[?1h"'
        end
      end

      describe '~' do
        it 'drops whatever 199~ is' do
          expect("b\e[199~ad")
            .to render_as 'bad'
        end

        it 'raises when raising for whatever 199~ is' do
          expect { described_class.parse("b\e[199~ad", unknown: :raise) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[199~"'
        end
      end

      describe 'a' do
        it 'drops whatever 199a is' do
          expect("b\e[199aud")
            .to render_as 'bud'
        end

        it 'raises when raising for whatever 199a is' do
          expect { described_class.parse("b\e[199aud", unknown: :raise) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[199a"'
        end
      end

      describe 'S' do
        it 'scrolls up, inserting newlines at the end' do
          expect("abc\ndef\e[S").to render_as "def\n"
        end

        it 'can be given an argument for the number of rows' do
          expect("abc\ndef\nghi\njkl\e[3S").to render_as "jkl\n\n\n"
        end

        it 'drops non-number args' do
          expect("a\e[>Sb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Sb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>S"'
        end
      end

      describe 'T' do
        it 'scrolls down, inserting newlines at the beginning' do
          expect("abc\ndef\e[T").to render_as "\nabc"
        end

        it 'can be given an argument for the number of rows' do
          expect("abc\ndef\nghi\njkl\e[3T").to render_as "\n\n\nabc"
        end

        it 'drops non-number args' do
          expect("a\e[>Tb").to render_as 'ab'
        end

        it 'raises non-number args when raising' do
          expect { described_class.parse("a\e[>Tb", unknown: described_class::RAISE) }
            .to raise_error described_class::UnknownCodeError, 'Unknown code "\e[>T"'
        end
      end
    end
  end

  describe 'README.md usage examples' do
    it 'describes basic usage' do
      expect(
        described_class.parse("th\ta string\e[3Gis is")
      ).to eq 'this is a string'
    end

    it 'suppresses color codes' do
      expect(
        described_class.parse("th\ta \e[31mstring\e[0m\e[3Gis is")
      ).to eq 'this is a string'
    end

    it 'optionally renders color codes' do
      expect(
        described_class.parse("th\ta \e[31mstring\e[0m\e[3Gis is", style: :render)
      ).to eq "this is a \e[31mstring\e[0m"
    end
  end

  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end
end
