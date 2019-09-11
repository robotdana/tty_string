RSpec::Matchers.define :render_as do |expected|
  match do |actual|
    @actual = TTYString.new(actual).to_s
    expect(@actual).to eq expected
  end
end

RSpec.describe TTYString do
  describe '#to_s' do
    it 'can render an empty string' do
      expect('').to render_as ''
    end

    it 'can render a string with no formatting information' do
      expect("a string").to render_as "a string"
    end

    describe '\b' do
      it 'backspaces when it meets a \b' do
        expect("ab\bc").to render_as "ac"
      end

      it "doesn't backspace when it meets a \b at the beginning of the line" do
        expect("\bab").to render_as "ab"
      end

      it "doesn't backspace up a line" do
        expect("ab\n\bcd").to render_as "ab\ncd"
      end
    end

    describe '\r' do
      it 'moves the cursor to the beginnig of the line without changing content' do
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
        expect("\ta").to render_as "        a"
      end

      it 'is backspaced a single space at a time' do
        expect("\t\ba").to render_as "       a"
      end

      it 'counts initial characters toward the 8 spaces' do
        expect("a\tb").to render_as "a       b"
      end

      it 'counts initial characters beyond the first 8' do
        expect("abcdefghij\tk").to render_as "abcdefghij      k"
      end

      it 'leaves existing characters unchanged' do
        expect("abc\r\tk").to render_as "abc     k"
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
          expect("abc\e[Ad").to render_as "abcd"
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
          expect("a\e[Cb").to render_as "a b"
        end

        it 'moves the cursor forward n characters' do
          expect("a\e[3Cb").to render_as "a   b"
        end
      end
      describe 'D' do
        it 'moves the cursor back' do
          expect("abc\e[Dd").to render_as "abd"
        end

        it 'does nothing at the screen edge' do
          expect("\e[Da").to render_as "a"
        end

        it 'moves the cursor back n characters' do
          expect("abcdefg\e[3Dh").to render_as "abcdhfg"
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
      describe 'G'
      describe 'H'
      describe 'J'
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
      end
      describe 'S'
      describe 'T'
      describe 'f'
    end
  end

  it "has a version number" do
    expect(TTYString::VERSION).not_to be nil
  end
end
