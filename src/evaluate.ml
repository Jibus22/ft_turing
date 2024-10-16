open Parsing

exception Infinite of string

let move_head tape direction =
  match (direction, tape.left, tape.right) with
  | Left, [], r -> { tape with head = Blank; right = tape.head :: r }
  | Left, hd :: tl, r -> { left = tl; head = hd; right = tape.head :: r }
  | Right, l, [] -> { tape with head = Blank; left = tape.head :: l }
  | Right, l, hd :: tl -> { head = hd; right = tl; left = tape.head :: l }

let check_infinite tape (st, sym) { next_state; move; write } =
  let stay_same_state = is_blank sym && st = next_state && sym = write in
  match (move, tape.left, tape.right) with
  | (Left, [], _ | Right, _, []) when stay_same_state ->
      raise (Infinite "Infinite dead end")
  | _ -> ()

let evaluate log tm =
  let rec loop current_st tape =
    if List.mem current_st tm.halt_states then tape
    else
      try
        let current_pair = (current_st, tape.head) in
        let action = Hashtbl.find tm.transitions current_pair in
        log tape (current_pair, action);
        check_infinite tape current_pair action;
        let tape = { tape with head = action.write } in
        let tape = move_head tape action.move in
        loop action.next_state tape
      with Not_found ->
        failwith @@ str_of_state current_st ^ " is not defined to read '"
        ^ str_of_symb tape.head ^ "'"
  in
  loop tm.current_state tm.tape
