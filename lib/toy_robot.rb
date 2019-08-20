require 'tabletop'

class ToyRobot
  NORTH = 'NORTH'.freeze
  SOUTH = 'SOUTH'.freeze
  EAST  = 'EAST'.freeze
  WEST  = 'WEST'.freeze
  DIRECTIONS = [NORTH, EAST, SOUTH, WEST].freeze
  private_constant :DIRECTIONS, :NORTH, :SOUTH, :EAST, :WEST

  class UserError      < StandardError; end
  class PlacementError < UserError; end
  class MovementError  < UserError; end

  def initialize(tabletop:)
    raise ArgumentError, 'Tabletop object required' unless tabletop.is_a?(Tabletop)

    @tabletop = tabletop
    @placed   = false
  end

  def place(x:, y:, direction:)
    raise ArgumentError,  'x and y must be integer'                      unless x.is_a?(Integer) && y.is_a?(Integer)
    raise ArgumentError,  'direction must be a string'                   unless direction.is_a?(String)
    raise PlacementError, 'direction must be NORTH, SOUTH, EAST or WEST' unless DIRECTIONS.include?(direction)
    raise PlacementError, 'x and y coordinates outside of tabletop'      unless valid_position?(x, y)

    @x, @y = x, y
    @direction_index = DIRECTIONS.index(direction)

    @placed = true
    self
  end

  def move
    check_placed
    @x, @y = position_after_move
    self
  end

  def right
    check_placed    
    @direction_index == last_direction_index ? @direction_index = 0 : @direction_index += 1
    self
  end

  def left
    check_placed
    @direction_index == 0 ? @direction_index = last_direction_index : @direction_index -= 1
    self
  end

  def report
    check_placed
    [@x, @y, DIRECTIONS[@direction_index]]
  end

  private

  def valid_position?(x, y)
    @tabletop.valid_position?(x: x, y: y)
  end

  def last_direction_index
    DIRECTIONS.size - 1
  end

  def check_placed
    raise PlacementError, 'Robot not placed on the table yet' unless @placed
  end
  
  def position_after_move
    future_x, future_y = @x, @y

    case DIRECTIONS[@direction_index]
    when NORTH
      future_y += 1
    when SOUTH
      future_y -= 1
    when EAST
      future_x += 1
    when WEST
      future_x -= 1
    end
    raise MovementError, "You'll fall off the table!" unless valid_position?(future_x, future_y)

    [future_x, future_y]
  end
end