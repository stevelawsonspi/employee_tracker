require 'toy_robot_navigator'

RSpec.describe ToyRobotNavigator, type: :lib do
  let(:navigator) { ToyRobotNavigator.new }

  describe '#action' do
    it 'type checks action' do
      error_message = 'Action must be a string'
      expect([navigator.action(  5.5), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action(:MOVE), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action(   99), navigator.errors]).to eq ['error', [error_message]]
    end

    it 'rejects invalid actions' do
      error_message = 'Action must be PLACE, MOVE, LEFT, RIGHT or REPORT'
      expect([navigator.action('JUMP'   ), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('Explode'), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('place'  ), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('Move'   ), navigator.errors]).to eq ['error', [error_message]]
    end

    it '"bubbles up" errors from ToyRobot' do
      error_message = 'Robot not placed on the table yet'
      expect([navigator.action('MOVE'  ), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('LEFT'  ), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('RIGHT' ), navigator.errors]).to eq ['error', [error_message]]
      expect([navigator.action('REPORT'), navigator.errors]).to eq ['error', [error_message]]

      expect([navigator.action('PLACE'), navigator.errors]).to eq ['error', ['x and y must be integer']]
      expect([navigator.action('PLACE', 9, 9, 'NORTH'), navigator.errors]).to eq ['error', ['x and y coordinates outside of tabletop']]
    end

    it 'moves robot as expected' do
      expect(navigator.action('PLACE', 0, 0, 'NORTH')).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('RIGHT' )).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('LEFT'  )).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('REPORT')).to eq [2, 2, 'NORTH']
      expect(navigator.action('PLACE', 3, 3, 'EAST')).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('LEFT'  )).to eq 'ok'
      expect(navigator.action('MOVE'  )).to eq 'ok'
      expect(navigator.action('REPORT')).to eq [4, 4, 'NORTH']
    end
  end
end
