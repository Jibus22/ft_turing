type enclose = Parens | Hook

let w = 80

let get_header name =
  let len = String.length name in
  let padding = (w / 2) - (len / 2) in
  let full = String.make w '*' ^ "\n"
  and empty = "*" ^ String.make (w - 2) ' ' ^ "*\n"
  and name =
    let pad_s = padding - 1
    and pad_e = padding - if len mod 2 = 0 then 1 else 2 in
    "*" ^ String.make pad_s ' ' ^ name ^ String.make pad_e ' ' ^ "*\n"
  in
  full ^ empty ^ name ^ empty ^ full

let show_str_lst ?(enclosing = Parens) lst =
  let body = List.fold_left (fun acc str -> acc ^ str ^ ", ") "" lst in
  let body = String.sub body 0 @@ (String.length body - 2) in
  match enclosing with Parens -> "(" ^ body ^ ")" | Hook -> "[" ^ body ^ "]"

let list_to_str title convert lst =
  title ^ ": " ^ show_str_lst (List.map convert lst) ~enclosing:Hook

let get_str title convert data = title ^ ": " ^ convert data

let transition_tuple_to_str acc ((st, sym), tr) =
  let open Parsing in
  let rhs { next_state; move; write } =
    show_str_lst
      [ str_of_state next_state; str_of_symb write; str_of_direction move ]
  and lhs = show_str_lst [ str_of_state st; str_of_symb sym ] in
  acc ^ lhs ^ " -> " ^ rhs tr ^ "\n"

let transition_tbl_to_str table =
  Hashtbl.to_seq table |> List.of_seq
  |> List.sort (fun ((st1, _), _) ((st2, _), _) -> Stdlib.compare st1 st2)
  |> List.fold_left transition_tuple_to_str ""

let display_input name alphabet tm =
  let open Parsing in
  let states, halt_states, transitions, current_state = tm in
  print_endline @@ get_header name;
  print_endline @@ list_to_str "Alphabet" str_of_symb alphabet;
  print_endline @@ list_to_str "States" str_of_state states;
  print_endline @@ list_to_str "Finals" str_of_state halt_states;
  print_endline @@ get_str "Initial" str_of_state current_state;
  print_endline @@ transition_tbl_to_str transitions
