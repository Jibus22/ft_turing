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

let usage_msg = "ft_turing [-verbose] <json> <input>"
let verbose = ref false
let inputs = ref []
let speclist = [ ("-verbose", Arg.Set verbose, "Output debug information") ]
let anon_fun input = inputs := input :: !inputs

let get_inputs inputs =
  match List.rev inputs with
  | json_file :: user_input :: t -> Some (json_file, user_input)
  | _ -> None

let str_to_state s = State s

let str_to_direction_exn s =
  match String.uppercase_ascii s with
  | "LEFT" -> Left
  | "RIGHT" -> Right
  | _ -> raise (Parsing_error "Direction must be \"LEFT\" or \"RIGHT\"")

let to_tm_type to_f to_type jsontype = to_f jsontype |> to_type
let to_state = to_tm_type Yojson.Basic.Util.to_string str_to_state
let to_direction = to_tm_type Yojson.Basic.Util.to_string str_to_direction_exn
let str_of_state = function State s -> s
let str_of_symb = function Blank -> "Blank" | Symbol c -> String.make 1 c
let difference l1 l2 = List.filter (fun elem -> not @@ List.mem elem l2) l1

let debugjson name blank initial alphabet states finals =
  Printf.printf "name: %s - blank: %s - initial: %s\n" name blank
  @@ str_of_state initial;
  List.iter (fun s -> Printf.printf "%s " (str_of_symb s)) alphabet;
  print_endline "";
  List.iter (function s -> Printf.printf "%s - " (str_of_state s)) states;
  print_endline "";
  List.iter (fun a -> Printf.printf "%s - " (str_of_state a)) finals

let mem_exn name json =
  match Yojson.Basic.Util.member name json with
  | `Null -> raise (Parsing_error ("member \"" ^ name ^ "\" is missing"))
  | x -> x

let to_state_exn states a =
  let state = to_state a in
  match List.mem state states with
  | true -> state
  | false ->
      raise
        (Parsing_error
           ("state " ^ str_of_state state ^ " is not part of the given states"))

let get_transition_table json states halt_states to_sym_check =
  let open Yojson.Basic.Util in
  let transitions = json |> mem_exn "transitions"
  and transition_table = Hashtbl.create 10 in
  List.iter (fun state ->
      transitions
      |> mem_exn (str_of_state state)
      |> to_list
      |> List.iter (fun assoc ->
             let read = assoc |> mem_exn "read" |> to_sym_check
             and write = assoc |> mem_exn "write" |> to_sym_check
             and next_state = assoc |> mem_exn "to_state" |> to_state_exn states
             and move = assoc |> mem_exn "action" |> to_direction in
             Hashtbl.add transition_table (state, read)
               { write; next_state; move }))
  @@ difference states halt_states;
  transition_table

let get_symbols blank alphabet =
  let err_len s = "'" ^ s ^ "' must be 1 character long"
  and err_alphabet s = "symbol '" ^ s ^ "' is not part of the given alphabet" in
  let check_symbol sym =
    if String.length sym <> 1 then raise (Parsing_error (err_len sym))
    else if not @@ List.mem sym alphabet then
      raise (Parsing_error (err_alphabet sym))
    else sym
  in
  let str_to_symbol s =
    match check_symbol s = blank with
    | true -> Blank
    | false -> Symbol (String.get s 0)
  in
  (str_to_symbol, str_to_symbol blank, List.map str_to_symbol alphabet)

let parse_json json =
  let open Yojson.Basic.Util in
  let name = json |> mem_exn "name" |> to_string
  and blank = json |> mem_exn "blank" |> to_string
  and alphabet = json |> mem_exn "alphabet" |> to_list |> List.map to_string in
  let str_to_symbol, blank, alphabet = get_symbols blank alphabet
  and states = json |> mem_exn "states" |> to_list |> List.map to_state in
  let current_state = json |> mem_exn "initial" |> to_state_exn states
  and halt_states =
    json |> mem_exn "finals" |> to_list |> List.map (to_state_exn states)
  in
  let transitions =
    get_transition_table json states halt_states
    @@ to_tm_type to_string str_to_symbol
  in
  ( name,
    alphabet,
    str_to_symbol,
    (states, halt_states, transitions, current_state) )

let get_tape input str_to_symbol =
  let tape =
    input |> String.to_seq |> List.of_seq
    |> List.map (fun c -> String.make 1 c |> str_to_symbol)
  in
  let has_blank = function Blank -> true | Symbol _ -> false in
  if List.length @@ List.filter has_blank tape > 0 then
    raise (Parsing_error "input must not contains blank character")
  else
    match tape with
    | [] -> raise (Parsing_error "input must not be empty")
    | hd :: t -> { left = []; head = hd; right = t @ [ Blank ] }

let () =
  Arg.parse speclist anon_fun usage_msg;
  match get_inputs !inputs with
  | None ->
      Arg.usage speclist usage_msg;
      exit 1
  | Some (json_filename, user_input) -> (
      Printf.printf "json: %s ; input: %s\n" json_filename user_input;
      try
        let json = Yojson.Basic.from_file json_filename in
        let name, alphabet, str_to_symbol, tm = parse_json json in
        let tape = get_tape user_input str_to_symbol in
        exit 0
      with
      | Parsing_error msg -> Printf.eprintf "Parsing error: %s\n" msg
      | e ->
          let msg = Printexc.to_string e
          and stack = Printexc.get_backtrace () in
          Printf.eprintf "there was an error: %s%s\n" msg stack)

(* debugjson name blank initial alphabet states finals; *)

(* List.iter *)
(*   (fun a -> Format.printf "Parsed to %a" Yojson.Basic.pp a; print_endline "\n----\n") *)
(*   transitions'; *)
