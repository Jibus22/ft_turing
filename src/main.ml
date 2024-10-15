open Parsing
open Print

let usage_msg = "ft_turing [-verbose] <json> <input>"
let verbose = ref false
let inputs = ref []
let speclist = [ ("-verbose", Arg.Set verbose, "Output debug information") ]
let anon_fun input = inputs := input :: !inputs

let get_inputs inputs =
  match List.rev inputs with
  | json_file :: user_input :: t -> Some (json_file, user_input)
  | _ -> None

let logger v tape tr =
  print_endline @@ tape_to_str tape
  ^ if v then " " ^ transition_tuple_to_str tr else ""

let () =
  Arg.parse speclist anon_fun usage_msg;
  match get_inputs !inputs with
  | None ->
      Arg.usage speclist usage_msg;
      exit 1
  | Some (json_filename, user_input) -> (
      try
        let name, alphabet, tm = parse_input json_filename user_input in
        if !verbose then display_input name alphabet tm;
        Evaluate.evaluate (logger !verbose) tm
      with
      | Parsing_error msg -> Printf.eprintf "Parsing error: %s\n" msg
      | e ->
          let msg = Printexc.to_string e
          and stack = Printexc.get_backtrace () in
          Printf.eprintf "there was an error: %s%s\n" msg stack)
