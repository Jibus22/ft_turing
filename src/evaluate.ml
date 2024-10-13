open Parsing
open Print

let move_head tape direction =
  match (direction, tape.left, tape.right) with
  | Left, [], r -> { tape with head = Blank; right = tape.head :: r }
  | Left, hd :: tl, r -> { left = tl; head = hd; right = tape.head :: r }
  | Right, l, [] -> { tape with head = Blank; left = tape.head :: l }
  | Right, l, hd :: tl -> { head = hd; right = tl; left = tape.head :: l }

let evaluate tm =
  let rec loop current_st tape =
    if List.mem current_st tm.halt_states then "stop"
    else
      let _ = print_endline @@ tape_to_str tape in
      let transition = Hashtbl.find tm.transitions (current_st, tape.head) in
      let tape = { tape with head = transition.write } in
      let tape = move_head tape transition.move in
      loop transition.next_state tape
  in
  loop tm.current_state tm.tape
