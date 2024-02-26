module.exports = grammar({
  name: "ros2",

  rules: {
    source_file: ($) =>
      repeat(
        // Options available
        choice($.comment, $.separator, $.field)
      ),
    comment: ($) => seq($.comment_char, $.comment_string),
    comment_char: () => "#",
    comment_string: () => /.*/,

    separator: () => "---",

    field: ($) => seq($.field_type, $.field_name, optional($.field_value)),
    // Add arrays
    field_type: ($) =>
      choice(
        $.built_in_type,
        $.custom_interface_type,
        $.bounded_string,
        $.array_type
      ),
    built_in_type: () =>
      choice(
        "bool",
        "boolean",
        "char",
        "float32",
        "float64",
        "int8",
        "uint8",
        "int16",
        "uint16",
        "int32",
        "uint32",
        "int64",
        "uint64",
        "string",
        "wstring"
      ),
    custom_interface_type: () =>
      /[a-zA-Z_][a-zA-Z0-9_]*(\/[a-zA-Z_][a-zA-Z0-9_]*)*/,
    bounded_string: ($) => seq($.built_in_type, "<=", $.number),
    array_type: ($) =>
      choice(
        // Unbounded array
        seq(choice($.built_in_type, $.custom_interface_type), "[", "]"),
        // fixed-size array
        seq(
          choice($.built_in_type, $.custom_interface_type),
          "[",
          $.number,
          "]"
        ),
        // Upper-bounded array
        seq(
          choice($.built_in_type, $.custom_interface_type),
          "[<=",
          $.number,
          "]"
        ),
        seq(
          choice($.built_in_type, $.custom_interface_type),
          "<=",
          $.number,
          "[]"
        ),
        seq(
          choice($.built_in_type, $.custom_interface_type),
          "<=",
          $.number,
          "[<=",
          $.number,
          "]"
        )
      ),

    number: () => /\d+/,

    field_name: ($) => choice($.name_string, $.const_field),
    // Regex that follows the field_names rules for names https://docs.ros.org/en/humble/Concepts/Basic/About-Interfaces.html#field-names
    name_string: () => /[a-z]([a-z0-9]*(_[a-z0-9]+)*)?/,
    const_field: ($) => seq($.const_name, "=", $.field_value),
    const_name: () => /[A-Z_]+/,
    field_value: ($) =>
      choice($.integer_value, $.float_value, $.string_value, $.array),
    integer_value: () => /-?\d+/,
    float_value: () => /-?\d+\.\d+/,
    // FIXME: There is a weird behavior where the string value without quotes breaks
    // the next instance
    string_value: ($) => choice(/'[^']*'/, /"[^"]*"/),
    array: ($) => seq("[", seq($._value, repeat(seq(",", $._value))), "]"),
    _value: ($) => choice($.integer_value, $.float_value, $.string_value),
  },
});
