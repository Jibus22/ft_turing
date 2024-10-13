open Parsing

type enclose = Parenthesis | Hook

let w = 80

let red = "\027[31m"
and green = "\027[32m"
and blue = "\027[34m"
and reset = "\027[0m"

let color_text color text = Printf.sprintf "%s%s%s" color text reset

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

let show_str_lst ?(enclose = Parenthesis) ?(sep = ", ") lst =
  let body = List.fold_left (fun acc str -> acc ^ str ^ sep) "" lst in
  let body = String.sub body 0 @@ (String.length body - String.length sep) in
  match enclose with
  | Parenthesis -> "(" ^ body ^ ")"
  | Hook -> "[" ^ body ^ "]"

let list_to_str title convert lst =
  title ^ ": " ^ show_str_lst (List.map convert lst) ~enclose:Hook

let get_str title convert data = title ^ ": " ^ convert data

let transition_tuple_to_str acc ((st, sym), tr) =
  let rhs { next_state; move; write } =
    show_str_lst
      [ str_of_state next_state; str_of_symb write; str_of_direction move ]
  and lhs = show_str_lst [ str_of_state st; str_of_symb sym ] in
  acc ^ lhs ^ " -> " ^ rhs tr ^ "\n"

let transition_tbl_to_str table =
  Hashtbl.to_seq table |> List.of_seq
  |> List.sort (fun ((st1, _), _) ((st2, _), _) -> Stdlib.compare st1 st2)
  |> List.fold_left transition_tuple_to_str ""

let tape_to_str { left; head; right } =
  let left = List.map str_of_symb left |> List.rev
  and head = [ color_text blue @@ str_of_symb head ]
  and right = List.map str_of_symb right in
  show_str_lst ~sep:"" ~enclose:Hook @@ left @ head @ right

let display_input name alphabet
    { states; halt_states; current_state; transitions; tape } =
  (* let states, halt_states, transitions, current_state = tm in *)
  print_endline @@ get_header name;
  print_endline @@ list_to_str "Alphabet" str_of_symb alphabet;
  print_endline @@ list_to_str "States" str_of_state states;
  print_endline @@ list_to_str "Finals" str_of_state halt_states;
  print_endline @@ get_str "Initial" str_of_state current_state;
  print_endline @@ transition_tbl_to_str transitions;
  print_endline @@ tape_to_str tape;
  print_endline @@ String.make w '*'
