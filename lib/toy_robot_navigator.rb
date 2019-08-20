# Note: If #action returns false, use #errors to see why.

require 'tabletop'
require 'toy_robot'

class ToyRobotNavigator
  PLACE   = 'PLACE'.freeze
  MOVE    = 'MOVE'.freeze
  LEFT    = 'LEFT'.freeze
  RIGHT   = 'RIGHT'.freeze
  REPORT  = 'REPORT'.freeze
  ACTIONS = [PLACE, MOVE, LEFT, RIGHT, REPORT].freeze
  private_constant :PLACE, :MOVE, :LEFT, :RIGHT, :REPORT, :ACTIONS

  attr_accessor :errors

  def initialize
    @errors    = []
    @tabletop  = Tabletop.new
    @toy_robot = ToyRobot.new(tabletop: @tabletop)
  end

  def action(action_name, *args)
    clear_errors
    add_error 'Action must be a string'                           if !errors? && !action_name.is_a?(String)
    add_error 'Action must be PLACE, MOVE, LEFT, RIGHT or REPORT' if !errors? && !ACTIONS.include?(action_name)
    return 'error' if errors?

    begin
      result = 'ok' # default
      case action_name
      when PLACE
        x, y, direction = *args
        @toy_robot.place(x: x, y: y, direction: direction)
      when REPORT
        result = @toy_robot.report
      else # move, left, right
        @toy_robot.send(action_name.downcase)
      end
    rescue StandardError => e
      add_error e.message
      result = 'error'
    end
    result
  end

  private

  def clear_errors
    @errors = []
  end

  def add_error(message)
    errors << message
  end

  def errors?
    @errors.size > 0
  end
end
