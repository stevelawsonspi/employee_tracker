# README for Toy Robot Simulator Challenge

I used a rails app with rspec as I expect this is the environment.  I used regular Ruby objects instead of Rails Action* objects to save time.

### Please copy the following files into `/lib`...
`tabletop.rb`
`toy_robot.rb`
`toy_robot_navigator.rb`

### Please copy the following files into `/spec/lib`...
`tabletop_spec.rb`
`toy_robot_spec.rb`
`toy_robot_navigator_spec_.rb`

## To run the tests...
`bundle exec rspec spec/lib/tabletop_spec.rb`
`bundle exec rspec spec/lib/toy_robot_spec.rb`
`bundle exec rspec spec/lib/toy_robot_navigator_spec.rb`

## Running the app...
`toy_robot_navigator = ToyRobotNavigator.new`
`toy_robot_navigator.action('MOVE')                 # error`
`toy_robot_navigator.errors                         # ['Robot not placed on the table yet']`
`toy_robot_navigator.action('PLACE', 0, 0, 'NORTH') # ok`
`toy_robot_navigator.action('MOVE')                 # ok`
`toy_robot_navigator.action('RIGHT')                # ok`
`toy_robot_navigator.action('MOVE')                 # ok`
`toy_robot_navigator.action('LEFT')                 # ok`
`toy_robot_navigator.action('LEFT')                 # ok`
`toy_robot_navigator.action('REPORT')               # [1, 1, 'WEST']`

