RSpec.describe TTYString do
  describe '#to_s' do
    describe '\b' do
      it 'backspaces when it meets a \b' do
        expect(TTYString.new("a\bb").to_s).to eq "b"
      end

      it "doesn't backspace when it meets a \b at the beginning of the line" do
        expect(TTYString.new("\bb").to_s).to eq "b"
      end
    end
  end

  it "has a version number" do
    expect(TTYString::VERSION).not_to be nil
  end
end
