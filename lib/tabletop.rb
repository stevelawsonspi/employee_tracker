class Tabletop
  DEFAULT_X_SIZE = 5.freeze
  DEFAULT_Y_SIZE = 5.freeze
  private_constant :DEFAULT_X_SIZE, :DEFAULT_Y_SIZE

  def initialize(x_size: DEFAULT_X_SIZE, y_size: DEFAULT_Y_SIZE)
    raise ArgumentError, 'size params must be integer'    unless x_size.is_a?(Integer) && y_size.is_a?(Integer)
    raise ArgumentError, 'size params cannot be negative' if x_size < 0 || y_size < 0

    @x_size = x_size
    @y_size = y_size
  end

  def valid_position?(x:, y:)
    raise ArgumentError, 'x and y must be integer' unless x.is_a?(Integer) && y.is_a?(Integer)

    (x >=0 && x <= @x_size-1) && (y >=0 && y <= @y_size-1)
  end
end
