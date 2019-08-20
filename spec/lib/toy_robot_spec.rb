require 'toy_robot'

RSpec.describe ToyRobot, type: :lib do
  let(:toy_robot) { ToyRobot.new(tabletop: Tabletop.new(x_size: 5, y_size: 5)) }

  describe '#initialise' do
    it 'accepts a valid Tabletop' do
      expect { ToyRobot.new(tabletop: Tabletop.new) }.not_to raise_exception
    end
          
    it 'requires a valid Tabletop' do
      error_message = 'Tabletop object required'
      expect { ToyRobot.new(tabletop:   nil) }.to raise_exception(ArgumentError, error_message)
      expect { ToyRobot.new(tabletop: 'wtf') }.to raise_exception(ArgumentError, error_message)
      expect { ToyRobot.new(tabletop:     5) }.to raise_exception(ArgumentError, error_message)
    end
  end

  describe '#place' do
    it 'accepts valid parameter types' do
      expect { toy_robot.place(x:   0, y:   0, direction: 'NORTH') }.not_to raise_exception
    end

    it 'rejects invalid parameter types' do
      error_message = 'x and y must be integer'
      expect { toy_robot.place(x: 'a', y:   0, direction: 'NORTH') }.to raise_exception(ArgumentError, error_message)
      expect { toy_robot.place(x:   0, y: 'b', direction: 'NORTH') }.to raise_exception(ArgumentError, error_message)
      expect { toy_robot.place(x: 5.0, y:   0, direction: 'NORTH') }.to raise_exception(ArgumentError, error_message)
      expect { toy_robot.place(x:   0, y: 3.0, direction: 'NORTH') }.to raise_exception(ArgumentError, error_message)

      error_message = 'direction must be a string'
      expect { toy_robot.place(x: 0, y: 0, direction:      0) }.to raise_exception(ArgumentError, error_message)
      expect { toy_robot.place(x: 0, y: 0, direction:    5.0) }.to raise_exception(ArgumentError, error_message)
      expect { toy_robot.place(x: 0, y: 0, direction: :NORTH) }.to raise_exception(ArgumentError, error_message)
    end

    it "allows valid x and y coordinates" do
      expect { toy_robot.place(x:  0, y:  0, direction: 'NORTH') }.not_to raise_exception
      expect { toy_robot.place(x:  4, y:  4, direction: 'NORTH') }.not_to raise_exception
      expect { toy_robot.place(x:  3, y:  2, direction: 'NORTH') }.not_to raise_exception
    end

    it "rejects x and y coordinates off the tabletop" do
      error_message = 'x and y coordinates outside of tabletop' 
      expect { toy_robot.place(x: -1, y:  0, direction: 'NORTH') }.to raise_exception(ToyRobot::PlacementError, error_message)
      expect { toy_robot.place(x:  0, y: -1, direction: 'NORTH') }.to raise_exception(ToyRobot::PlacementError, error_message)
      expect { toy_robot.place(x:  6, y:  0, direction: 'NORTH') }.to raise_exception(ToyRobot::PlacementError, error_message)
      expect { toy_robot.place(x:  0, y: 99, direction: 'NORTH') }.to raise_exception(ToyRobot::PlacementError, error_message)

    end

    it 'accepts valid direction values' do
      expect { toy_robot.place(x: 0, y: 0, direction: 'NORTH') }.not_to raise_exception
      expect { toy_robot.place(x: 0, y: 0, direction: 'EAST' ) }.not_to raise_exception
      expect { toy_robot.place(x: 0, y: 0, direction: 'SOUTH') }.not_to raise_exception
      expect { toy_robot.place(x: 0, y: 0, direction: 'WEST' ) }.not_to raise_exception
    end

    it 'rejects invalid direction values' do
      error_message = 'direction must be NORTH, SOUTH, EAST or WEST' 
      expect { toy_robot.place(x: 0, y: 0, direction: 'north') }.to raise_exception(ToyRobot::PlacementError, error_message)
      expect { toy_robot.place(x: 0, y: 0, direction: 'OMG'  ) }.to raise_exception(ToyRobot::PlacementError, error_message)
      expect { toy_robot.place(x: 0, y: 0, direction: 'help!') }.to raise_exception(ToyRobot::PlacementError, error_message)
    end

    it 'sets the state' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').report).to eq [0, 0, 'NORTH']
      expect(toy_robot.place(x: 4, y: 3, direction: 'SOUTH').report).to eq [4, 3, 'SOUTH']
      expect(toy_robot.place(x: 3, y: 2, direction: 'EAST' ).report).to eq [3, 2, 'EAST' ]
      expect(toy_robot.place(x: 2, y: 1, direction: 'WEST' ).report).to eq [2, 1, 'WEST' ]
    end

    it 'can be repositioned' do
      toy_robot.place(x: 0, y: 0, direction: 'NORTH')
      expect(toy_robot.place(x: 4, y: 3, direction: 'SOUTH').report).to eq [4, 3, 'SOUTH']
    end
  end

  describe '#move' do
    it 'fails if not already placed' do
      expect { toy_robot.move }.to raise_exception(ToyRobot::PlacementError, 'Robot not placed on the table yet')
    end

    it 'detects if out of bounds' do
      error_message = "You'll fall off the table!"
      expect { toy_robot.place(x: 0, y: 1, direction: 'WEST' ).move }.to raise_exception(ToyRobot::MovementError, error_message)
      expect { toy_robot.place(x: 2, y: 0, direction: 'SOUTH').move }.to raise_exception(ToyRobot::MovementError, error_message)
      expect { toy_robot.place(x: 3, y: 4, direction: 'NORTH').move }.to raise_exception(ToyRobot::MovementError, error_message)
      expect { toy_robot.place(x: 4, y: 2, direction: 'EAST' ).move }.to raise_exception(ToyRobot::MovementError, error_message)
    end

    it 'moves correctly in bounds' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').move.report).to eq [0, 1, 'NORTH']
      expect(toy_robot.place(x: 4, y: 3, direction: 'SOUTH').move.report).to eq [4, 2, 'SOUTH']
      expect(toy_robot.place(x: 3, y: 2, direction: 'EAST' ).move.report).to eq [4, 2, 'EAST' ]
      expect(toy_robot.place(x: 2, y: 1, direction: 'WEST' ).move.report).to eq [1, 1, 'WEST' ]
    end
  end

  describe '#right' do
    it 'fails if not already placed' do
      expect { toy_robot.right }.to raise_exception(ToyRobot::PlacementError, 'Robot not placed on the table yet')
    end

    it 'positions correctly' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').right.report).to eq [0, 0, 'EAST' ]
      expect(toy_robot.place(x: 0, y: 0, direction: 'SOUTH').right.report).to eq [0, 0, 'WEST' ]
      expect(toy_robot.place(x: 0, y: 0, direction: 'EAST' ).right.report).to eq [0, 0, 'SOUTH']
      expect(toy_robot.place(x: 0, y: 0, direction: 'WEST' ).right.report).to eq [0, 0, 'NORTH']
    end
  end

  describe '#left' do
    it 'fails if not already placed' do
      expect { toy_robot.left }.to raise_exception(ToyRobot::PlacementError, 'Robot not placed on the table yet')
    end

    it 'positions correctly' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').left.report).to eq [0, 0, 'WEST' ]
      expect(toy_robot.place(x: 0, y: 0, direction: 'SOUTH').left.report).to eq [0, 0, 'EAST' ]
      expect(toy_robot.place(x: 0, y: 0, direction: 'EAST' ).left.report).to eq [0, 0, 'NORTH']
      expect(toy_robot.place(x: 0, y: 0, direction: 'WEST' ).left.report).to eq [0, 0, 'SOUTH']
    end
  end

  describe '#report' do
    it 'fails if not already placed' do
      expect { toy_robot.report }.to raise_exception(ToyRobot::PlacementError, 'Robot not placed on the table yet')
    end

    it 'reports correctly' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').report).to eq [0, 0, 'NORTH']
    end
  end

  describe 'supports method chaining' do
    it 'chains with correct result' do
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').move.right.move.left.report).to eq [1, 1, 'NORTH']
      expect(toy_robot.place(x: 0, y: 0, direction: 'NORTH').right.move.move.left.report).to eq [2, 0, 'NORTH']
    end
  end

  describe 'ignores potential falls' do
    it 'can keep moving after potential fall' do
      expect { toy_robot.place(x: 0, y: 0, direction: 'SOUTH').move }.to raise_exception(ToyRobot::MovementError)

      expect(toy_robot.report).to           eq [0, 0, 'SOUTH']
      expect(toy_robot.left.move.report).to eq [1, 0, 'EAST' ]
    end
  end
end
