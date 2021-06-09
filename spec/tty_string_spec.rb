# frozen_string_literal: true

RSpec::Matchers.define :render_as do |expected|
  match do |actual|
    @actual = TTYString.parse(actual)
    expect(@actual).to eq expected
  end
end

RSpec::Matchers.define :render_with_style_as do |expected|
  match do |actual|
    @actual = TTYString.parse(actual, clear_style: false)
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
      end

      describe 'B' do
        it 'moves the cursor down' do
          expect("a\e[Bb").to render_as "a\n b"
        end

        it 'moves the cursor down n lines' do
          expect("a\e[3Bb").to render_as "a\n\n\n b"
        end
      end

      describe 'C' do
        it 'moves the cursor forward' do
          expect("a\e[Cb").to render_as 'a b'
        end

        it 'moves the cursor forward n characters' do
          expect("a\e[3Cb").to render_as 'a   b'
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
      end

      describe 'E' do
        it 'moves the cursor to the beginning of the line 1 line down' do
          expect("abcd\e[2D\e[Efg").to render_as "abcd\nfg"
        end

        it 'moves the cursor to the beginning of the line n lines down' do
          expect("abcd\e[2D\e[2Efg").to render_as "abcd\n\nfg"
        end
      end

      describe 'F' do
        it 'moves the cursor to the beginning of the line 1 line p' do
          expect("abcd\nef\e[Fgh").to render_as "ghcd\nef"
        end

        it 'moves the cursor to the beginning of the line n lines up' do
          expect("abcd\n\n\nef\e[2Fgh").to render_as "abcd\ngh\n\nef"
        end
      end

      describe 'G' do
        it 'moves the cursor to that column' do
          expect("abc\e[2Gd").to render_as 'adc'
        end

        it 'defaults to 1' do
          expect("abc\e[Gd").to render_as 'dbc'
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

        it 'returns the original text when given unrecognized arguments' do
          expect("abc\ndef\nghi\e[2;2H\e[4J").to render_as "abc\nd\e[4J\nghi"
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

        it 'returns the original text when given unrecognized arguments' do
          expect("abc\ndef\nghi\e[2;2H\e[3K").to render_as "abc\nd\e[3K\nghi"
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
          expect("\e[31mred\e[36;37;38;0m plain").to render_as 'red plain'
        end

        it 'leaves simple style codes untouched when clear_style: false' do
          expect("\e[31mred\e[0m plain")
            .to render_with_style_as "\e[31mred\e[0m plain"
        end

        it 'leaves complex style codes untouched when clear_style: false' do
          expect("\e[31mred\e[36;37;38;0m plain")
            .to render_with_style_as "\e[31mred\e[36;37;38;0m plain"
        end
      end

      describe '?2004h' do
        it 'strips bracketed paste mode noise' do
          expect("\e[?2004h\e[200~echo 'hello'\n\e[201~\e[?2004l")
            .to render_as "echo 'hello'\n"
        end
      end

      describe 'S' do
        it 'scrolls up, inserting newlines at the end' do
          expect("abc\ndef\e[S").to render_as "def\n"
        end

        it 'can be given an argument for the number of rows' do
          expect("abc\ndef\nghi\njkl\e[3S").to render_as "jkl\n\n\n"
        end
      end

      describe 'T' do
        it 'scrolls down, inserting newlines at the beginning' do
          expect("abc\ndef\e[T").to render_as "\nabc"
        end

        it 'can be given an argument for the number of rows' do
          expect("abc\ndef\nghi\njkl\e[3T").to render_as "\n\n\nabc"
        end
      end
    end
  end

  describe 'README.md usage examples' do
    it 'describes basic usage' do
      expect(
        described_class.new("th\ta string\e[3Gis is").to_s
      ).to eq 'this is a string'
    end

    it 'suppresses color codes' do
      expect(
        described_class.new("th\ta \e[31mstring\e[0m\e[3Gis is").to_s
      ).to eq 'this is a string'
    end

    it 'optionally does not suppress color codes' do
      expect(
        described_class
          .new("th\ta \e[31mstring\e[0m\e[3Gis is", clear_style: false).to_s
      ).to eq "this is a \e[31mstring\e[0m"
    end
  end

  it 'has a version number' do
    expect(TTYString::VERSION).not_to be nil
  end
end
