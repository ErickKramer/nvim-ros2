#include "tree_sitter/parser.h"

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-field-initializers"
#endif

#define LANGUAGE_VERSION 14
#define STATE_COUNT 40
#define LARGE_STATE_COUNT 6
#define SYMBOL_COUNT 49
#define ALIAS_COUNT 0
#define TOKEN_COUNT 34
#define EXTERNAL_TOKEN_COUNT 0
#define FIELD_COUNT 0
#define MAX_ALIAS_SEQUENCE_LENGTH 6
#define PRODUCTION_ID_COUNT 1

enum ts_symbol_identifiers {
  sym_comment_char = 1,
  sym_comment_string = 2,
  sym_separator = 3,
  anon_sym_bool = 4,
  anon_sym_boolean = 5,
  anon_sym_char = 6,
  anon_sym_float32 = 7,
  anon_sym_float64 = 8,
  anon_sym_int8 = 9,
  anon_sym_uint8 = 10,
  anon_sym_int16 = 11,
  anon_sym_uint16 = 12,
  anon_sym_int32 = 13,
  anon_sym_uint32 = 14,
  anon_sym_int64 = 15,
  anon_sym_uint64 = 16,
  anon_sym_string = 17,
  anon_sym_wstring = 18,
  sym_custom_interface_type = 19,
  anon_sym_LT_EQ = 20,
  anon_sym_LBRACK = 21,
  anon_sym_RBRACK = 22,
  anon_sym_LBRACK_LT_EQ = 23,
  anon_sym_LBRACK_RBRACK = 24,
  sym_number = 25,
  sym_name_string = 26,
  anon_sym_EQ = 27,
  sym_const_name = 28,
  sym_integer_value = 29,
  sym_float_value = 30,
  aux_sym_string_value_token1 = 31,
  aux_sym_string_value_token2 = 32,
  anon_sym_COMMA = 33,
  sym_source_file = 34,
  sym_comment = 35,
  sym_field = 36,
  sym_field_type = 37,
  sym_built_in_type = 38,
  sym_bounded_string = 39,
  sym_array_type = 40,
  sym_field_name = 41,
  sym_const_field = 42,
  sym_field_value = 43,
  sym_string_value = 44,
  sym_array = 45,
  sym__value = 46,
  aux_sym_source_file_repeat1 = 47,
  aux_sym_array_repeat1 = 48,
};

static const char * const ts_symbol_names[] = {
  [ts_builtin_sym_end] = "end",
  [sym_comment_char] = "comment_char",
  [sym_comment_string] = "comment_string",
  [sym_separator] = "separator",
  [anon_sym_bool] = "bool",
  [anon_sym_boolean] = "boolean",
  [anon_sym_char] = "char",
  [anon_sym_float32] = "float32",
  [anon_sym_float64] = "float64",
  [anon_sym_int8] = "int8",
  [anon_sym_uint8] = "uint8",
  [anon_sym_int16] = "int16",
  [anon_sym_uint16] = "uint16",
  [anon_sym_int32] = "int32",
  [anon_sym_uint32] = "uint32",
  [anon_sym_int64] = "int64",
  [anon_sym_uint64] = "uint64",
  [anon_sym_string] = "string",
  [anon_sym_wstring] = "wstring",
  [sym_custom_interface_type] = "custom_interface_type",
  [anon_sym_LT_EQ] = "<=",
  [anon_sym_LBRACK] = "[",
  [anon_sym_RBRACK] = "]",
  [anon_sym_LBRACK_LT_EQ] = "[<=",
  [anon_sym_LBRACK_RBRACK] = "[]",
  [sym_number] = "number",
  [sym_name_string] = "name_string",
  [anon_sym_EQ] = "=",
  [sym_const_name] = "const_name",
  [sym_integer_value] = "integer_value",
  [sym_float_value] = "float_value",
  [aux_sym_string_value_token1] = "string_value_token1",
  [aux_sym_string_value_token2] = "string_value_token2",
  [anon_sym_COMMA] = ",",
  [sym_source_file] = "source_file",
  [sym_comment] = "comment",
  [sym_field] = "field",
  [sym_field_type] = "field_type",
  [sym_built_in_type] = "built_in_type",
  [sym_bounded_string] = "bounded_string",
  [sym_array_type] = "array_type",
  [sym_field_name] = "field_name",
  [sym_const_field] = "const_field",
  [sym_field_value] = "field_value",
  [sym_string_value] = "string_value",
  [sym_array] = "array",
  [sym__value] = "_value",
  [aux_sym_source_file_repeat1] = "source_file_repeat1",
  [aux_sym_array_repeat1] = "array_repeat1",
};

static const TSSymbol ts_symbol_map[] = {
  [ts_builtin_sym_end] = ts_builtin_sym_end,
  [sym_comment_char] = sym_comment_char,
  [sym_comment_string] = sym_comment_string,
  [sym_separator] = sym_separator,
  [anon_sym_bool] = anon_sym_bool,
  [anon_sym_boolean] = anon_sym_boolean,
  [anon_sym_char] = anon_sym_char,
  [anon_sym_float32] = anon_sym_float32,
  [anon_sym_float64] = anon_sym_float64,
  [anon_sym_int8] = anon_sym_int8,
  [anon_sym_uint8] = anon_sym_uint8,
  [anon_sym_int16] = anon_sym_int16,
  [anon_sym_uint16] = anon_sym_uint16,
  [anon_sym_int32] = anon_sym_int32,
  [anon_sym_uint32] = anon_sym_uint32,
  [anon_sym_int64] = anon_sym_int64,
  [anon_sym_uint64] = anon_sym_uint64,
  [anon_sym_string] = anon_sym_string,
  [anon_sym_wstring] = anon_sym_wstring,
  [sym_custom_interface_type] = sym_custom_interface_type,
  [anon_sym_LT_EQ] = anon_sym_LT_EQ,
  [anon_sym_LBRACK] = anon_sym_LBRACK,
  [anon_sym_RBRACK] = anon_sym_RBRACK,
  [anon_sym_LBRACK_LT_EQ] = anon_sym_LBRACK_LT_EQ,
  [anon_sym_LBRACK_RBRACK] = anon_sym_LBRACK_RBRACK,
  [sym_number] = sym_number,
  [sym_name_string] = sym_name_string,
  [anon_sym_EQ] = anon_sym_EQ,
  [sym_const_name] = sym_const_name,
  [sym_integer_value] = sym_integer_value,
  [sym_float_value] = sym_float_value,
  [aux_sym_string_value_token1] = aux_sym_string_value_token1,
  [aux_sym_string_value_token2] = aux_sym_string_value_token2,
  [anon_sym_COMMA] = anon_sym_COMMA,
  [sym_source_file] = sym_source_file,
  [sym_comment] = sym_comment,
  [sym_field] = sym_field,
  [sym_field_type] = sym_field_type,
  [sym_built_in_type] = sym_built_in_type,
  [sym_bounded_string] = sym_bounded_string,
  [sym_array_type] = sym_array_type,
  [sym_field_name] = sym_field_name,
  [sym_const_field] = sym_const_field,
  [sym_field_value] = sym_field_value,
  [sym_string_value] = sym_string_value,
  [sym_array] = sym_array,
  [sym__value] = sym__value,
  [aux_sym_source_file_repeat1] = aux_sym_source_file_repeat1,
  [aux_sym_array_repeat1] = aux_sym_array_repeat1,
};

static const TSSymbolMetadata ts_symbol_metadata[] = {
  [ts_builtin_sym_end] = {
    .visible = false,
    .named = true,
  },
  [sym_comment_char] = {
    .visible = true,
    .named = true,
  },
  [sym_comment_string] = {
    .visible = true,
    .named = true,
  },
  [sym_separator] = {
    .visible = true,
    .named = true,
  },
  [anon_sym_bool] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_boolean] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_char] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_float32] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_float64] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_int8] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_uint8] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_int16] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_uint16] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_int32] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_uint32] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_int64] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_uint64] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_string] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_wstring] = {
    .visible = true,
    .named = false,
  },
  [sym_custom_interface_type] = {
    .visible = true,
    .named = true,
  },
  [anon_sym_LT_EQ] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_RBRACK] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACK_LT_EQ] = {
    .visible = true,
    .named = false,
  },
  [anon_sym_LBRACK_RBRACK] = {
    .visible = true,
    .named = false,
  },
  [sym_number] = {
    .visible = true,
    .named = true,
  },
  [sym_name_string] = {
    .visible = true,
    .named = true,
  },
  [anon_sym_EQ] = {
    .visible = true,
    .named = false,
  },
  [sym_const_name] = {
    .visible = true,
    .named = true,
  },
  [sym_integer_value] = {
    .visible = true,
    .named = true,
  },
  [sym_float_value] = {
    .visible = true,
    .named = true,
  },
  [aux_sym_string_value_token1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_string_value_token2] = {
    .visible = false,
    .named = false,
  },
  [anon_sym_COMMA] = {
    .visible = true,
    .named = false,
  },
  [sym_source_file] = {
    .visible = true,
    .named = true,
  },
  [sym_comment] = {
    .visible = true,
    .named = true,
  },
  [sym_field] = {
    .visible = true,
    .named = true,
  },
  [sym_field_type] = {
    .visible = true,
    .named = true,
  },
  [sym_built_in_type] = {
    .visible = true,
    .named = true,
  },
  [sym_bounded_string] = {
    .visible = true,
    .named = true,
  },
  [sym_array_type] = {
    .visible = true,
    .named = true,
  },
  [sym_field_name] = {
    .visible = true,
    .named = true,
  },
  [sym_const_field] = {
    .visible = true,
    .named = true,
  },
  [sym_field_value] = {
    .visible = true,
    .named = true,
  },
  [sym_string_value] = {
    .visible = true,
    .named = true,
  },
  [sym_array] = {
    .visible = true,
    .named = true,
  },
  [sym__value] = {
    .visible = false,
    .named = true,
  },
  [aux_sym_source_file_repeat1] = {
    .visible = false,
    .named = false,
  },
  [aux_sym_array_repeat1] = {
    .visible = false,
    .named = false,
  },
};

static const TSSymbol ts_alias_sequences[PRODUCTION_ID_COUNT][MAX_ALIAS_SEQUENCE_LENGTH] = {
  [0] = {0},
};

static const uint16_t ts_non_terminal_alias_map[] = {
  0,
};

static const TSStateId ts_primary_state_ids[STATE_COUNT] = {
  [0] = 0,
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 6,
  [7] = 7,
  [8] = 8,
  [9] = 9,
  [10] = 10,
  [11] = 11,
  [12] = 12,
  [13] = 13,
  [14] = 14,
  [15] = 15,
  [16] = 16,
  [17] = 17,
  [18] = 18,
  [19] = 19,
  [20] = 20,
  [21] = 21,
  [22] = 22,
  [23] = 23,
  [24] = 24,
  [25] = 25,
  [26] = 26,
  [27] = 27,
  [28] = 28,
  [29] = 29,
  [30] = 30,
  [31] = 31,
  [32] = 32,
  [33] = 33,
  [34] = 34,
  [35] = 35,
  [36] = 36,
  [37] = 37,
  [38] = 38,
  [39] = 39,
};

static bool ts_lex(TSLexer *lexer, TSStateId state) {
  START_LEXER();
  eof = lexer->eof(lexer);
  switch (state) {
    case 0:
      if (eof) ADVANCE(15);
      if (lookahead == '"') ADVANCE(1);
      if (lookahead == '#') ADVANCE(16);
      if (lookahead == '\'') ADVANCE(2);
      if (lookahead == ',') ADVANCE(90);
      if (lookahead == '-') ADVANCE(3);
      if (lookahead == '<') ADVANCE(7);
      if (lookahead == '=') ADVANCE(84);
      if (lookahead == '[') ADVANCE(77);
      if (lookahead == ']') ADVANCE(78);
      if (lookahead == 'b') ADVANCE(62);
      if (lookahead == 'c') ADVANCE(51);
      if (lookahead == 'f') ADVANCE(56);
      if (lookahead == 'i') ADVANCE(59);
      if (lookahead == 's') ADVANCE(69);
      if (lookahead == 'u') ADVANCE(54);
      if (lookahead == 'w') ADVANCE(68);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(0)
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(81);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 1:
      if (lookahead == '"') ADVANCE(89);
      if (lookahead != 0) ADVANCE(1);
      END_STATE();
    case 2:
      if (lookahead == '\'') ADVANCE(88);
      if (lookahead != 0) ADVANCE(2);
      END_STATE();
    case 3:
      if (lookahead == '-') ADVANCE(4);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(86);
      END_STATE();
    case 4:
      if (lookahead == '-') ADVANCE(19);
      END_STATE();
    case 5:
      if (lookahead == '<') ADVANCE(7);
      if (lookahead == '[') ADVANCE(77);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(5)
      if (('a' <= lookahead && lookahead <= 'z')) ADVANCE(83);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_') ADVANCE(85);
      END_STATE();
    case 6:
      if (lookahead == '<') ADVANCE(8);
      if (lookahead == ']') ADVANCE(80);
      END_STATE();
    case 7:
      if (lookahead == '=') ADVANCE(75);
      END_STATE();
    case 8:
      if (lookahead == '=') ADVANCE(79);
      END_STATE();
    case 9:
      if (lookahead == '[') ADVANCE(6);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(9)
      if (('a' <= lookahead && lookahead <= 'z')) ADVANCE(83);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_') ADVANCE(85);
      END_STATE();
    case 10:
      if (lookahead == ']') ADVANCE(78);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(10)
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(82);
      END_STATE();
    case 11:
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(87);
      END_STATE();
    case 12:
      if (('0' <= lookahead && lookahead <= '9') ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(83);
      END_STATE();
    case 13:
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 14:
      if (eof) ADVANCE(15);
      if (lookahead == '"') ADVANCE(1);
      if (lookahead == '#') ADVANCE(16);
      if (lookahead == '\'') ADVANCE(2);
      if (lookahead == ',') ADVANCE(90);
      if (lookahead == '-') ADVANCE(3);
      if (lookahead == '[') ADVANCE(76);
      if (lookahead == ']') ADVANCE(78);
      if (lookahead == 'b') ADVANCE(62);
      if (lookahead == 'c') ADVANCE(51);
      if (lookahead == 'f') ADVANCE(56);
      if (lookahead == 'i') ADVANCE(59);
      if (lookahead == 's') ADVANCE(69);
      if (lookahead == 'u') ADVANCE(54);
      if (lookahead == 'w') ADVANCE(68);
      if (('\t' <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') SKIP(14)
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(86);
      if (('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 15:
      ACCEPT_TOKEN(ts_builtin_sym_end);
      END_STATE();
    case 16:
      ACCEPT_TOKEN(sym_comment_char);
      END_STATE();
    case 17:
      ACCEPT_TOKEN(sym_comment_string);
      if (lookahead == '\t' ||
          (11 <= lookahead && lookahead <= '\r') ||
          lookahead == ' ') ADVANCE(17);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(18);
      END_STATE();
    case 18:
      ACCEPT_TOKEN(sym_comment_string);
      if (lookahead != 0 &&
          lookahead != '\n') ADVANCE(18);
      END_STATE();
    case 19:
      ACCEPT_TOKEN(sym_separator);
      END_STATE();
    case 20:
      ACCEPT_TOKEN(anon_sym_bool);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'e') ADVANCE(47);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 21:
      ACCEPT_TOKEN(anon_sym_boolean);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 22:
      ACCEPT_TOKEN(anon_sym_char);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 23:
      ACCEPT_TOKEN(anon_sym_float32);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 24:
      ACCEPT_TOKEN(anon_sym_float64);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 25:
      ACCEPT_TOKEN(anon_sym_int8);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 26:
      ACCEPT_TOKEN(anon_sym_uint8);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 27:
      ACCEPT_TOKEN(anon_sym_int16);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 28:
      ACCEPT_TOKEN(anon_sym_uint16);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 29:
      ACCEPT_TOKEN(anon_sym_int32);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 30:
      ACCEPT_TOKEN(anon_sym_uint32);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 31:
      ACCEPT_TOKEN(anon_sym_int64);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 32:
      ACCEPT_TOKEN(anon_sym_uint64);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 33:
      ACCEPT_TOKEN(anon_sym_string);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 34:
      ACCEPT_TOKEN(anon_sym_wstring);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 35:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '1') ADVANCE(44);
      if (lookahead == '3') ADVANCE(37);
      if (lookahead == '6') ADVANCE(41);
      if (lookahead == '8') ADVANCE(25);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 36:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '1') ADVANCE(45);
      if (lookahead == '3') ADVANCE(38);
      if (lookahead == '6') ADVANCE(42);
      if (lookahead == '8') ADVANCE(26);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 37:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '2') ADVANCE(29);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 38:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '2') ADVANCE(30);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 39:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '2') ADVANCE(23);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 40:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '3') ADVANCE(39);
      if (lookahead == '6') ADVANCE(43);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 41:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '4') ADVANCE(31);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 42:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '4') ADVANCE(32);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 43:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '4') ADVANCE(24);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 44:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '6') ADVANCE(27);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 45:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == '6') ADVANCE(28);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 46:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'a') ADVANCE(65);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 47:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'a') ADVANCE(58);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 48:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'a') ADVANCE(71);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('b' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 49:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'g') ADVANCE(33);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 50:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'g') ADVANCE(34);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 51:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'h') ADVANCE(46);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 52:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'i') ADVANCE(57);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 53:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'i') ADVANCE(60);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 54:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'i') ADVANCE(61);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 55:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'l') ADVANCE(20);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 56:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'l') ADVANCE(64);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 57:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'n') ADVANCE(49);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 58:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'n') ADVANCE(21);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 59:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'n') ADVANCE(70);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 60:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'n') ADVANCE(50);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 61:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'n') ADVANCE(72);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 62:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'o') ADVANCE(63);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 63:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'o') ADVANCE(55);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 64:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'o') ADVANCE(48);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 65:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'r') ADVANCE(22);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 66:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'r') ADVANCE(52);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 67:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 'r') ADVANCE(53);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 68:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 's') ADVANCE(73);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 69:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 't') ADVANCE(66);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 70:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 't') ADVANCE(35);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 71:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 't') ADVANCE(40);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 72:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 't') ADVANCE(36);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 73:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (lookahead == 't') ADVANCE(67);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 74:
      ACCEPT_TOKEN(sym_custom_interface_type);
      if (lookahead == '/') ADVANCE(13);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_' ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(74);
      END_STATE();
    case 75:
      ACCEPT_TOKEN(anon_sym_LT_EQ);
      END_STATE();
    case 76:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      END_STATE();
    case 77:
      ACCEPT_TOKEN(anon_sym_LBRACK);
      if (lookahead == '<') ADVANCE(8);
      END_STATE();
    case 78:
      ACCEPT_TOKEN(anon_sym_RBRACK);
      END_STATE();
    case 79:
      ACCEPT_TOKEN(anon_sym_LBRACK_LT_EQ);
      END_STATE();
    case 80:
      ACCEPT_TOKEN(anon_sym_LBRACK_RBRACK);
      END_STATE();
    case 81:
      ACCEPT_TOKEN(sym_number);
      if (lookahead == '.') ADVANCE(11);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(81);
      END_STATE();
    case 82:
      ACCEPT_TOKEN(sym_number);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(82);
      END_STATE();
    case 83:
      ACCEPT_TOKEN(sym_name_string);
      if (lookahead == '_') ADVANCE(12);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('a' <= lookahead && lookahead <= 'z')) ADVANCE(83);
      END_STATE();
    case 84:
      ACCEPT_TOKEN(anon_sym_EQ);
      END_STATE();
    case 85:
      ACCEPT_TOKEN(sym_const_name);
      if (('0' <= lookahead && lookahead <= '9') ||
          ('A' <= lookahead && lookahead <= 'Z') ||
          lookahead == '_') ADVANCE(85);
      END_STATE();
    case 86:
      ACCEPT_TOKEN(sym_integer_value);
      if (lookahead == '.') ADVANCE(11);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(86);
      END_STATE();
    case 87:
      ACCEPT_TOKEN(sym_float_value);
      if (('0' <= lookahead && lookahead <= '9')) ADVANCE(87);
      END_STATE();
    case 88:
      ACCEPT_TOKEN(aux_sym_string_value_token1);
      END_STATE();
    case 89:
      ACCEPT_TOKEN(aux_sym_string_value_token2);
      END_STATE();
    case 90:
      ACCEPT_TOKEN(anon_sym_COMMA);
      END_STATE();
    default:
      return false;
  }
}

static const TSLexMode ts_lex_modes[STATE_COUNT] = {
  [0] = {.lex_state = 0},
  [1] = {.lex_state = 0},
  [2] = {.lex_state = 14},
  [3] = {.lex_state = 14},
  [4] = {.lex_state = 0},
  [5] = {.lex_state = 0},
  [6] = {.lex_state = 14},
  [7] = {.lex_state = 14},
  [8] = {.lex_state = 14},
  [9] = {.lex_state = 14},
  [10] = {.lex_state = 14},
  [11] = {.lex_state = 0},
  [12] = {.lex_state = 0},
  [13] = {.lex_state = 14},
  [14] = {.lex_state = 14},
  [15] = {.lex_state = 14},
  [16] = {.lex_state = 5},
  [17] = {.lex_state = 5},
  [18] = {.lex_state = 5},
  [19] = {.lex_state = 9},
  [20] = {.lex_state = 5},
  [21] = {.lex_state = 0},
  [22] = {.lex_state = 0},
  [23] = {.lex_state = 0},
  [24] = {.lex_state = 5},
  [25] = {.lex_state = 5},
  [26] = {.lex_state = 5},
  [27] = {.lex_state = 10},
  [28] = {.lex_state = 9},
  [29] = {.lex_state = 5},
  [30] = {.lex_state = 0},
  [31] = {.lex_state = 0},
  [32] = {.lex_state = 17},
  [33] = {.lex_state = 10},
  [34] = {.lex_state = 0},
  [35] = {.lex_state = 10},
  [36] = {.lex_state = 0},
  [37] = {.lex_state = 10},
  [38] = {.lex_state = 10},
  [39] = {.lex_state = 0},
};

static const uint16_t ts_parse_table[LARGE_STATE_COUNT][SYMBOL_COUNT] = {
  [0] = {
    [ts_builtin_sym_end] = ACTIONS(1),
    [sym_comment_char] = ACTIONS(1),
    [sym_separator] = ACTIONS(1),
    [anon_sym_bool] = ACTIONS(1),
    [anon_sym_boolean] = ACTIONS(1),
    [anon_sym_char] = ACTIONS(1),
    [anon_sym_float32] = ACTIONS(1),
    [anon_sym_float64] = ACTIONS(1),
    [anon_sym_int8] = ACTIONS(1),
    [anon_sym_uint8] = ACTIONS(1),
    [anon_sym_int16] = ACTIONS(1),
    [anon_sym_uint16] = ACTIONS(1),
    [anon_sym_int32] = ACTIONS(1),
    [anon_sym_uint32] = ACTIONS(1),
    [anon_sym_int64] = ACTIONS(1),
    [anon_sym_uint64] = ACTIONS(1),
    [anon_sym_string] = ACTIONS(1),
    [anon_sym_wstring] = ACTIONS(1),
    [sym_custom_interface_type] = ACTIONS(1),
    [anon_sym_LT_EQ] = ACTIONS(1),
    [anon_sym_LBRACK] = ACTIONS(1),
    [anon_sym_RBRACK] = ACTIONS(1),
    [anon_sym_LBRACK_LT_EQ] = ACTIONS(1),
    [sym_number] = ACTIONS(1),
    [anon_sym_EQ] = ACTIONS(1),
    [sym_integer_value] = ACTIONS(1),
    [sym_float_value] = ACTIONS(1),
    [aux_sym_string_value_token1] = ACTIONS(1),
    [aux_sym_string_value_token2] = ACTIONS(1),
    [anon_sym_COMMA] = ACTIONS(1),
  },
  [1] = {
    [sym_source_file] = STATE(34),
    [sym_comment] = STATE(5),
    [sym_field] = STATE(5),
    [sym_field_type] = STATE(20),
    [sym_built_in_type] = STATE(18),
    [sym_bounded_string] = STATE(25),
    [sym_array_type] = STATE(25),
    [aux_sym_source_file_repeat1] = STATE(5),
    [ts_builtin_sym_end] = ACTIONS(3),
    [sym_comment_char] = ACTIONS(5),
    [sym_separator] = ACTIONS(7),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_boolean] = ACTIONS(9),
    [anon_sym_char] = ACTIONS(9),
    [anon_sym_float32] = ACTIONS(9),
    [anon_sym_float64] = ACTIONS(9),
    [anon_sym_int8] = ACTIONS(9),
    [anon_sym_uint8] = ACTIONS(9),
    [anon_sym_int16] = ACTIONS(9),
    [anon_sym_uint16] = ACTIONS(9),
    [anon_sym_int32] = ACTIONS(9),
    [anon_sym_uint32] = ACTIONS(9),
    [anon_sym_int64] = ACTIONS(9),
    [anon_sym_uint64] = ACTIONS(9),
    [anon_sym_string] = ACTIONS(9),
    [anon_sym_wstring] = ACTIONS(9),
    [sym_custom_interface_type] = ACTIONS(11),
  },
  [2] = {
    [sym_field_value] = STATE(12),
    [sym_string_value] = STATE(10),
    [sym_array] = STATE(10),
    [ts_builtin_sym_end] = ACTIONS(13),
    [sym_comment_char] = ACTIONS(13),
    [sym_separator] = ACTIONS(13),
    [anon_sym_bool] = ACTIONS(15),
    [anon_sym_boolean] = ACTIONS(15),
    [anon_sym_char] = ACTIONS(15),
    [anon_sym_float32] = ACTIONS(15),
    [anon_sym_float64] = ACTIONS(15),
    [anon_sym_int8] = ACTIONS(15),
    [anon_sym_uint8] = ACTIONS(15),
    [anon_sym_int16] = ACTIONS(15),
    [anon_sym_uint16] = ACTIONS(15),
    [anon_sym_int32] = ACTIONS(15),
    [anon_sym_uint32] = ACTIONS(15),
    [anon_sym_int64] = ACTIONS(15),
    [anon_sym_uint64] = ACTIONS(15),
    [anon_sym_string] = ACTIONS(15),
    [anon_sym_wstring] = ACTIONS(15),
    [sym_custom_interface_type] = ACTIONS(15),
    [anon_sym_LBRACK] = ACTIONS(17),
    [sym_integer_value] = ACTIONS(19),
    [sym_float_value] = ACTIONS(21),
    [aux_sym_string_value_token1] = ACTIONS(23),
    [aux_sym_string_value_token2] = ACTIONS(23),
  },
  [3] = {
    [ts_builtin_sym_end] = ACTIONS(25),
    [sym_comment_char] = ACTIONS(25),
    [sym_separator] = ACTIONS(25),
    [anon_sym_bool] = ACTIONS(27),
    [anon_sym_boolean] = ACTIONS(27),
    [anon_sym_char] = ACTIONS(27),
    [anon_sym_float32] = ACTIONS(27),
    [anon_sym_float64] = ACTIONS(27),
    [anon_sym_int8] = ACTIONS(27),
    [anon_sym_uint8] = ACTIONS(27),
    [anon_sym_int16] = ACTIONS(27),
    [anon_sym_uint16] = ACTIONS(27),
    [anon_sym_int32] = ACTIONS(27),
    [anon_sym_uint32] = ACTIONS(27),
    [anon_sym_int64] = ACTIONS(27),
    [anon_sym_uint64] = ACTIONS(27),
    [anon_sym_string] = ACTIONS(27),
    [anon_sym_wstring] = ACTIONS(27),
    [sym_custom_interface_type] = ACTIONS(27),
    [anon_sym_LBRACK] = ACTIONS(25),
    [anon_sym_RBRACK] = ACTIONS(25),
    [sym_integer_value] = ACTIONS(27),
    [sym_float_value] = ACTIONS(25),
    [aux_sym_string_value_token1] = ACTIONS(25),
    [aux_sym_string_value_token2] = ACTIONS(25),
    [anon_sym_COMMA] = ACTIONS(25),
  },
  [4] = {
    [sym_comment] = STATE(4),
    [sym_field] = STATE(4),
    [sym_field_type] = STATE(20),
    [sym_built_in_type] = STATE(18),
    [sym_bounded_string] = STATE(25),
    [sym_array_type] = STATE(25),
    [aux_sym_source_file_repeat1] = STATE(4),
    [ts_builtin_sym_end] = ACTIONS(29),
    [sym_comment_char] = ACTIONS(31),
    [sym_separator] = ACTIONS(34),
    [anon_sym_bool] = ACTIONS(37),
    [anon_sym_boolean] = ACTIONS(37),
    [anon_sym_char] = ACTIONS(37),
    [anon_sym_float32] = ACTIONS(37),
    [anon_sym_float64] = ACTIONS(37),
    [anon_sym_int8] = ACTIONS(37),
    [anon_sym_uint8] = ACTIONS(37),
    [anon_sym_int16] = ACTIONS(37),
    [anon_sym_uint16] = ACTIONS(37),
    [anon_sym_int32] = ACTIONS(37),
    [anon_sym_uint32] = ACTIONS(37),
    [anon_sym_int64] = ACTIONS(37),
    [anon_sym_uint64] = ACTIONS(37),
    [anon_sym_string] = ACTIONS(37),
    [anon_sym_wstring] = ACTIONS(37),
    [sym_custom_interface_type] = ACTIONS(40),
  },
  [5] = {
    [sym_comment] = STATE(4),
    [sym_field] = STATE(4),
    [sym_field_type] = STATE(20),
    [sym_built_in_type] = STATE(18),
    [sym_bounded_string] = STATE(25),
    [sym_array_type] = STATE(25),
    [aux_sym_source_file_repeat1] = STATE(4),
    [ts_builtin_sym_end] = ACTIONS(43),
    [sym_comment_char] = ACTIONS(5),
    [sym_separator] = ACTIONS(45),
    [anon_sym_bool] = ACTIONS(9),
    [anon_sym_boolean] = ACTIONS(9),
    [anon_sym_char] = ACTIONS(9),
    [anon_sym_float32] = ACTIONS(9),
    [anon_sym_float64] = ACTIONS(9),
    [anon_sym_int8] = ACTIONS(9),
    [anon_sym_uint8] = ACTIONS(9),
    [anon_sym_int16] = ACTIONS(9),
    [anon_sym_uint16] = ACTIONS(9),
    [anon_sym_int32] = ACTIONS(9),
    [anon_sym_uint32] = ACTIONS(9),
    [anon_sym_int64] = ACTIONS(9),
    [anon_sym_uint64] = ACTIONS(9),
    [anon_sym_string] = ACTIONS(9),
    [anon_sym_wstring] = ACTIONS(9),
    [sym_custom_interface_type] = ACTIONS(11),
  },
};

static const uint16_t ts_small_parse_table[] = {
  [0] = 2,
    ACTIONS(47), 7,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
      anon_sym_LBRACK,
      sym_float_value,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    ACTIONS(49), 17,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
      sym_integer_value,
  [29] = 2,
    ACTIONS(51), 7,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
      anon_sym_LBRACK,
      sym_float_value,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    ACTIONS(53), 17,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
      sym_integer_value,
  [58] = 2,
    ACTIONS(55), 7,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
      anon_sym_LBRACK,
      sym_float_value,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    ACTIONS(57), 17,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
      sym_integer_value,
  [87] = 2,
    ACTIONS(59), 7,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
      anon_sym_LBRACK,
      sym_float_value,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    ACTIONS(61), 17,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
      sym_integer_value,
  [116] = 2,
    ACTIONS(63), 7,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
      anon_sym_LBRACK,
      sym_float_value,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    ACTIONS(65), 17,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
      sym_integer_value,
  [145] = 2,
    ACTIONS(67), 3,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
    ACTIONS(69), 16,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
  [169] = 2,
    ACTIONS(71), 3,
      ts_builtin_sym_end,
      sym_comment_char,
      sym_separator,
    ACTIONS(73), 16,
      anon_sym_bool,
      anon_sym_boolean,
      anon_sym_char,
      anon_sym_float32,
      anon_sym_float64,
      anon_sym_int8,
      anon_sym_uint8,
      anon_sym_int16,
      anon_sym_uint16,
      anon_sym_int32,
      anon_sym_uint32,
      anon_sym_int64,
      anon_sym_uint64,
      anon_sym_string,
      anon_sym_wstring,
      sym_custom_interface_type,
  [193] = 6,
    ACTIONS(17), 1,
      anon_sym_LBRACK,
    ACTIONS(19), 1,
      sym_integer_value,
    ACTIONS(21), 1,
      sym_float_value,
    STATE(9), 1,
      sym_field_value,
    ACTIONS(23), 2,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    STATE(10), 2,
      sym_string_value,
      sym_array,
  [214] = 4,
    ACTIONS(75), 1,
      sym_integer_value,
    ACTIONS(77), 1,
      sym_float_value,
    ACTIONS(23), 2,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    STATE(30), 2,
      sym_string_value,
      sym__value,
  [229] = 4,
    ACTIONS(79), 1,
      sym_integer_value,
    ACTIONS(81), 1,
      sym_float_value,
    ACTIONS(23), 2,
      aux_sym_string_value_token1,
      aux_sym_string_value_token2,
    STATE(23), 2,
      sym_string_value,
      sym__value,
  [244] = 4,
    ACTIONS(83), 1,
      anon_sym_LT_EQ,
    ACTIONS(85), 1,
      anon_sym_LBRACK,
    ACTIONS(87), 1,
      anon_sym_LBRACK_LT_EQ,
    ACTIONS(89), 2,
      sym_name_string,
      sym_const_name,
  [258] = 2,
    ACTIONS(93), 1,
      anon_sym_LBRACK,
    ACTIONS(91), 4,
      anon_sym_LT_EQ,
      anon_sym_LBRACK_LT_EQ,
      sym_name_string,
      sym_const_name,
  [268] = 4,
    ACTIONS(85), 1,
      anon_sym_LBRACK,
    ACTIONS(87), 1,
      anon_sym_LBRACK_LT_EQ,
    ACTIONS(95), 1,
      anon_sym_LT_EQ,
    ACTIONS(89), 2,
      sym_name_string,
      sym_const_name,
  [282] = 3,
    ACTIONS(97), 1,
      anon_sym_LBRACK_LT_EQ,
    ACTIONS(99), 1,
      anon_sym_LBRACK_RBRACK,
    ACTIONS(101), 2,
      sym_name_string,
      sym_const_name,
  [293] = 4,
    ACTIONS(103), 1,
      sym_name_string,
    ACTIONS(105), 1,
      sym_const_name,
    STATE(2), 1,
      sym_field_name,
    STATE(6), 1,
      sym_const_field,
  [306] = 3,
    ACTIONS(107), 1,
      anon_sym_RBRACK,
    ACTIONS(109), 1,
      anon_sym_COMMA,
    STATE(21), 1,
      aux_sym_array_repeat1,
  [316] = 3,
    ACTIONS(112), 1,
      anon_sym_RBRACK,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    STATE(21), 1,
      aux_sym_array_repeat1,
  [326] = 3,
    ACTIONS(114), 1,
      anon_sym_COMMA,
    ACTIONS(116), 1,
      anon_sym_RBRACK,
    STATE(22), 1,
      aux_sym_array_repeat1,
  [336] = 1,
    ACTIONS(118), 2,
      sym_name_string,
      sym_const_name,
  [341] = 1,
    ACTIONS(89), 2,
      sym_name_string,
      sym_const_name,
  [346] = 1,
    ACTIONS(120), 2,
      sym_name_string,
      sym_const_name,
  [351] = 2,
    ACTIONS(122), 1,
      anon_sym_RBRACK,
    ACTIONS(124), 1,
      sym_number,
  [358] = 2,
    ACTIONS(97), 1,
      anon_sym_LBRACK_LT_EQ,
    ACTIONS(99), 1,
      anon_sym_LBRACK_RBRACK,
  [365] = 1,
    ACTIONS(126), 2,
      sym_name_string,
      sym_const_name,
  [370] = 1,
    ACTIONS(107), 2,
      anon_sym_RBRACK,
      anon_sym_COMMA,
  [375] = 1,
    ACTIONS(99), 1,
      anon_sym_RBRACK,
  [379] = 1,
    ACTIONS(128), 1,
      sym_comment_string,
  [383] = 1,
    ACTIONS(130), 1,
      sym_number,
  [387] = 1,
    ACTIONS(132), 1,
      ts_builtin_sym_end,
  [391] = 1,
    ACTIONS(124), 1,
      sym_number,
  [395] = 1,
    ACTIONS(134), 1,
      anon_sym_RBRACK,
  [399] = 1,
    ACTIONS(136), 1,
      sym_number,
  [403] = 1,
    ACTIONS(138), 1,
      sym_number,
  [407] = 1,
    ACTIONS(140), 1,
      anon_sym_EQ,
};

static const uint32_t ts_small_parse_table_map[] = {
  [SMALL_STATE(6)] = 0,
  [SMALL_STATE(7)] = 29,
  [SMALL_STATE(8)] = 58,
  [SMALL_STATE(9)] = 87,
  [SMALL_STATE(10)] = 116,
  [SMALL_STATE(11)] = 145,
  [SMALL_STATE(12)] = 169,
  [SMALL_STATE(13)] = 193,
  [SMALL_STATE(14)] = 214,
  [SMALL_STATE(15)] = 229,
  [SMALL_STATE(16)] = 244,
  [SMALL_STATE(17)] = 258,
  [SMALL_STATE(18)] = 268,
  [SMALL_STATE(19)] = 282,
  [SMALL_STATE(20)] = 293,
  [SMALL_STATE(21)] = 306,
  [SMALL_STATE(22)] = 316,
  [SMALL_STATE(23)] = 326,
  [SMALL_STATE(24)] = 336,
  [SMALL_STATE(25)] = 341,
  [SMALL_STATE(26)] = 346,
  [SMALL_STATE(27)] = 351,
  [SMALL_STATE(28)] = 358,
  [SMALL_STATE(29)] = 365,
  [SMALL_STATE(30)] = 370,
  [SMALL_STATE(31)] = 375,
  [SMALL_STATE(32)] = 379,
  [SMALL_STATE(33)] = 383,
  [SMALL_STATE(34)] = 387,
  [SMALL_STATE(35)] = 391,
  [SMALL_STATE(36)] = 395,
  [SMALL_STATE(37)] = 399,
  [SMALL_STATE(38)] = 403,
  [SMALL_STATE(39)] = 407,
};

static const TSParseActionEntry ts_parse_actions[] = {
  [0] = {.entry = {.count = 0, .reusable = false}},
  [1] = {.entry = {.count = 1, .reusable = false}}, RECOVER(),
  [3] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_source_file, 0),
  [5] = {.entry = {.count = 1, .reusable = true}}, SHIFT(32),
  [7] = {.entry = {.count = 1, .reusable = true}}, SHIFT(5),
  [9] = {.entry = {.count = 1, .reusable = false}}, SHIFT(17),
  [11] = {.entry = {.count = 1, .reusable = false}}, SHIFT(16),
  [13] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field, 2),
  [15] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_field, 2),
  [17] = {.entry = {.count = 1, .reusable = true}}, SHIFT(15),
  [19] = {.entry = {.count = 1, .reusable = false}}, SHIFT(10),
  [21] = {.entry = {.count = 1, .reusable = true}}, SHIFT(10),
  [23] = {.entry = {.count = 1, .reusable = true}}, SHIFT(3),
  [25] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_string_value, 1),
  [27] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_string_value, 1),
  [29] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_source_file_repeat1, 2),
  [31] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_source_file_repeat1, 2), SHIFT_REPEAT(32),
  [34] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_source_file_repeat1, 2), SHIFT_REPEAT(4),
  [37] = {.entry = {.count = 2, .reusable = false}}, REDUCE(aux_sym_source_file_repeat1, 2), SHIFT_REPEAT(17),
  [40] = {.entry = {.count = 2, .reusable = false}}, REDUCE(aux_sym_source_file_repeat1, 2), SHIFT_REPEAT(16),
  [43] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_source_file, 1),
  [45] = {.entry = {.count = 1, .reusable = true}}, SHIFT(4),
  [47] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field_name, 1),
  [49] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_field_name, 1),
  [51] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 4),
  [53] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_array, 4),
  [55] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array, 3),
  [57] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_array, 3),
  [59] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_const_field, 3),
  [61] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_const_field, 3),
  [63] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field_value, 1),
  [65] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_field_value, 1),
  [67] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_comment, 2),
  [69] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_comment, 2),
  [71] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field, 3),
  [73] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_field, 3),
  [75] = {.entry = {.count = 1, .reusable = false}}, SHIFT(30),
  [77] = {.entry = {.count = 1, .reusable = true}}, SHIFT(30),
  [79] = {.entry = {.count = 1, .reusable = false}}, SHIFT(23),
  [81] = {.entry = {.count = 1, .reusable = true}}, SHIFT(23),
  [83] = {.entry = {.count = 1, .reusable = true}}, SHIFT(37),
  [85] = {.entry = {.count = 1, .reusable = false}}, SHIFT(27),
  [87] = {.entry = {.count = 1, .reusable = true}}, SHIFT(35),
  [89] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_field_type, 1),
  [91] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_built_in_type, 1),
  [93] = {.entry = {.count = 1, .reusable = false}}, REDUCE(sym_built_in_type, 1),
  [95] = {.entry = {.count = 1, .reusable = true}}, SHIFT(38),
  [97] = {.entry = {.count = 1, .reusable = true}}, SHIFT(33),
  [99] = {.entry = {.count = 1, .reusable = true}}, SHIFT(26),
  [101] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_bounded_string, 3),
  [103] = {.entry = {.count = 1, .reusable = true}}, SHIFT(6),
  [105] = {.entry = {.count = 1, .reusable = true}}, SHIFT(39),
  [107] = {.entry = {.count = 1, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2),
  [109] = {.entry = {.count = 2, .reusable = true}}, REDUCE(aux_sym_array_repeat1, 2), SHIFT_REPEAT(14),
  [112] = {.entry = {.count = 1, .reusable = true}}, SHIFT(7),
  [114] = {.entry = {.count = 1, .reusable = true}}, SHIFT(14),
  [116] = {.entry = {.count = 1, .reusable = true}}, SHIFT(8),
  [118] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_type, 3),
  [120] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_type, 4),
  [122] = {.entry = {.count = 1, .reusable = true}}, SHIFT(24),
  [124] = {.entry = {.count = 1, .reusable = true}}, SHIFT(31),
  [126] = {.entry = {.count = 1, .reusable = true}}, REDUCE(sym_array_type, 6),
  [128] = {.entry = {.count = 1, .reusable = true}}, SHIFT(11),
  [130] = {.entry = {.count = 1, .reusable = true}}, SHIFT(36),
  [132] = {.entry = {.count = 1, .reusable = true}},  ACCEPT_INPUT(),
  [134] = {.entry = {.count = 1, .reusable = true}}, SHIFT(29),
  [136] = {.entry = {.count = 1, .reusable = true}}, SHIFT(28),
  [138] = {.entry = {.count = 1, .reusable = true}}, SHIFT(19),
  [140] = {.entry = {.count = 1, .reusable = true}}, SHIFT(13),
};

#ifdef __cplusplus
extern "C" {
#endif
#ifdef _WIN32
#define extern __declspec(dllexport)
#endif

extern const TSLanguage *tree_sitter_ros2(void) {
  static const TSLanguage language = {
    .version = LANGUAGE_VERSION,
    .symbol_count = SYMBOL_COUNT,
    .alias_count = ALIAS_COUNT,
    .token_count = TOKEN_COUNT,
    .external_token_count = EXTERNAL_TOKEN_COUNT,
    .state_count = STATE_COUNT,
    .large_state_count = LARGE_STATE_COUNT,
    .production_id_count = PRODUCTION_ID_COUNT,
    .field_count = FIELD_COUNT,
    .max_alias_sequence_length = MAX_ALIAS_SEQUENCE_LENGTH,
    .parse_table = &ts_parse_table[0][0],
    .small_parse_table = ts_small_parse_table,
    .small_parse_table_map = ts_small_parse_table_map,
    .parse_actions = ts_parse_actions,
    .symbol_names = ts_symbol_names,
    .symbol_metadata = ts_symbol_metadata,
    .public_symbol_map = ts_symbol_map,
    .alias_map = ts_non_terminal_alias_map,
    .alias_sequences = &ts_alias_sequences[0][0],
    .lex_modes = ts_lex_modes,
    .lex_fn = ts_lex,
    .primary_state_ids = ts_primary_state_ids,
  };
  return &language;
}
#ifdef __cplusplus
}
#endif
