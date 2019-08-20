require 'tabletop'

RSpec.describe Tabletop, type: :lib do
  describe "#initialize" do
    it "allows no params" do
      expect { Tabletop.new }.not_to raise_exception
    end

    it "accepts valid params" do
      expect { Tabletop.new(x_size:   5, y_size:   5) }.not_to raise_exception
      expect { Tabletop.new(x_size:   1, y_size:   1) }.not_to raise_exception
      expect { Tabletop.new(x_size:  50, y_size:   6) }.not_to raise_exception
      expect { Tabletop.new(x_size:   3, y_size:  99) }.not_to raise_exception
      expect { Tabletop.new(x_size:  50, y_size:  50) }.not_to raise_exception
      expect { Tabletop.new(x_size: 200, y_size: 200) }.not_to raise_exception
    end

    it "checks parameter types" do
      error_message = 'size params must be integer'
      expect { Tabletop.new(x_size: 'a', y_size:   5) }.to raise_exception(ArgumentError, error_message)
      expect { Tabletop.new(x_size:   5, y_size: 5.0) }.to raise_exception(ArgumentError, error_message)
      expect { Tabletop.new(x_size:  :x, y_size:   5) }.to raise_exception(ArgumentError, error_message)
    end

    it "does not allow negatives" do
      error_message = 'size params cannot be negative'
      expect { Tabletop.new(x_size: -5, y_size:  5) }.to raise_exception(ArgumentError, error_message)
      expect { Tabletop.new(x_size:  5, y_size: -5) }.to raise_exception(ArgumentError, error_message)
    end
  end

  describe "#valid_position?" do
    let(:tabletop) { Tabletop.new(x_size: 5, y_size: 5) }

    it "only allows Integers" do
      error_message = 'x and y must be integer'
      expect { tabletop.valid_position?(x: 'a', y:  5) }.to raise_exception(ArgumentError, error_message)
      expect { tabletop.valid_position?(x:   3, y: :a) }.to raise_exception(ArgumentError, error_message)
    end

    it "detects all good positions" do
      5.times do |x| # .times starts at 0
        5.times do |y|
          expect(tabletop.valid_position?(x: x, y: y)).to eq(true), "expected true for x=#{x}, y=#{y}"
        end
      end
    end

    it "detects bad positions" do
      expect(tabletop.valid_position?(x:  1, y: -1)).to eq false
      expect(tabletop.valid_position?(x: -5, y:  4)).to eq false
      expect(tabletop.valid_position?(x:  3, y:  6)).to eq false
      expect(tabletop.valid_position?(x: 20, y:  3)).to eq false
    end
  end
end
