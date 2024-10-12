type symbol = Blank | Symbol of char
type direction = Left | Right
type state = State of string
type transition = { next_state : state; move : direction; write : symbol }
type tape = { left : symbol list; head : symbol; right : symbol list }

type turing_machine = {
  tape : tape;
  states : state list;
  halt_states : state list;
  current_state : state;
  transitions : (state * symbol, transition) Hashtbl.t;
}

exception Parsing_error of string

val str_of_state : state -> string
val str_of_symb : symbol -> string
val str_of_direction : direction -> string

val get_symbols :
  string -> string list -> (string -> symbol) * symbol * symbol list

val parse_json :
  Yojson.Basic.t ->
  string
  * symbol list
  * (string -> symbol)
  * (state list * state list * (state * symbol, transition) Hashtbl.t * state)

val get_tape : String.t -> (string -> symbol) -> tape
