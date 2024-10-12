let usage_msg = "ft_turing [-verbose] <json> <input>"
let verbose = ref false
let inputs = ref []
let speclist = [ ("-verbose", Arg.Set verbose, "Output debug information") ]
let anon_fun input = inputs := input :: !inputs

let get_inputs inputs =
  match List.rev inputs with
  | json_file :: user_input :: t -> Some (json_file, user_input)
  | _ -> None

let debugjson name blank initial alphabet states finals =
  let open Parsing in
  Printf.printf "name: %s - blank: %s - initial: %s\n" name blank
  @@ str_of_state initial;
  List.iter (fun s -> Printf.printf "%s " (str_of_symb s)) alphabet;
  print_endline "";
  List.iter (function s -> Printf.printf "%s - " (str_of_state s)) states;
  print_endline "";
  List.iter (fun a -> Printf.printf "%s - " (str_of_state a)) finals

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
        let name, alphabet, str_to_symbol, tm = Parsing.parse_json json in
        let tape = Parsing.get_tape user_input str_to_symbol in
        exit 0
      with
      | Parsing.Parsing_error msg -> Printf.eprintf "Parsing error: %s\n" msg
      | e ->
          let msg = Printexc.to_string e
          and stack = Printexc.get_backtrace () in
          Printf.eprintf "there was an error: %s%s\n" msg stack)

(* debugjson name blank initial alphabet states finals; *)

(* List.iter *)
(*   (fun a -> Format.printf "Parsed to %a" Yojson.Basic.pp a; print_endline "\n----\n") *)
(*   transitions'; *)
