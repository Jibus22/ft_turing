open Parsing

let test_str_of_state () =
  str_of_state @@ State "str1" |> Alcotest.(check string) "same string" "str1";
  str_of_state @@ State "str2" |> Alcotest.(check string) "same string" "str2";
  str_of_state @@ State "1" |> Alcotest.(check string) "same string" "1"

let test_str_of_symb () =
  str_of_symb @@ Symbol 'a' |> Alcotest.(check string) "same string" "a";
  str_of_symb @@ Symbol 'b' |> Alcotest.(check string) "same string" "b";
  str_of_symb @@ Symbol '1' |> Alcotest.(check string) "same string" "1";
  str_of_symb Blank |> Alcotest.(check string) "same string" ""

let test_str_of_direction () =
  str_of_direction Left |> Alcotest.(check string) "same string" "Left";
  str_of_direction Right |> Alcotest.(check string) "same string" "Right"

let pp_tape fmt t =
  let conv acc a = acc ^ str_of_symb a in
  Format.fprintf fmt "{ left = %s; head = %s; right = %s}"
    (List.fold_left conv "" t.left)
    (str_of_symb t.head)
    (List.fold_left conv "" t.right)

let equal_tape t1 t2 =
  let slstequal = List.for_all2 (fun a b -> str_of_symb a = str_of_symb b) in
  t1.head = t2.head && slstequal t1.left t2.left && slstequal t1.right t2.right

let tape_testable = Alcotest.testable pp_tape equal_tape

let test_get_tape_1 () =
  let str_to_symbol s =
    match s with s when s = "." -> Blank | _ -> Symbol (String.get s 0)
  in
  let r1 = [ Symbol '1'; Symbol '+'; Symbol '1'; Symbol '=' ]
  and r2 = [ Symbol '1'; Symbol '0'; Symbol '1'; Symbol '=' ]
  and r3 = [ Symbol '1'; Symbol '+'; Symbol '0'; Symbol '1' ] in
  let expected = { left = []; head = Symbol '1'; right = [] } in
  get_tape "11+1=" str_to_symbol
  |> Alcotest.(check tape_testable) "same tape" { expected with right = r1 };
  get_tape "1101=" str_to_symbol
  |> Alcotest.(check tape_testable) "same tape" { expected with right = r2 };
  get_tape "11+01" str_to_symbol
  |> Alcotest.(check tape_testable) "same tape" { expected with right = r3 }

let () =
  Alcotest.run "Parsing"
    [
      ( "'str_of_x' conversion",
        [
          Alcotest.test_case "str_of_state" `Quick test_str_of_state;
          Alcotest.test_case "str_of_symb" `Quick test_str_of_symb;
          Alcotest.test_case "str_of_direction" `Quick test_str_of_direction;
        ] );
      ("get_tape", [ Alcotest.test_case "get_tape 11+1" `Quick test_get_tape_1 ]);
    ]
