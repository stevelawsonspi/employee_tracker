

my_session = {}
my_session[:some_data] = "hi"

my_session[:some_data]

my_session[:some_array] = ["hi", "there"]

my_session[:some_array]
# ["hi", "there"]

@my_array = my_session[:some_array] ? my_session[:some_array] : []

@my_array << "something else"

@my_array 
# ["hi", "there", "something else"]

my_session[:some_array] = @my_array

my_session[:some_array]
# ["hi", "there", "something else"]


