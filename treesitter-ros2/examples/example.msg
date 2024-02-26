# Examples of basic msg fields
int32 my_int
string my_string
builtin_interfaces/msg/Time time

# Examples of arrays and bounded types
int32[] unbounded_integer_array
int32[5] five_integers_array
int32[<=5] up_to_five_integers_array

# Bounded types
string<=10 bounded_string
string[<=5] up_to_five_unbounded_strings
string<=10[] unbounded_array_of_strings_up_to_ten_characters_each
string<=10[<=5] up_to_five_strings_up_to_ten_characters_each

# Default Values
uint8 x 42
int16 y -2000
string full_name "John Doe"
int32[] samples [-200, -100, 0, 100, 200]

# Examples of constants
int32 X=123
int32 Y=-123
string FOO="foo"
string BAR='bar'
string[] BAZ=["baz"]

