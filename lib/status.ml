(* status.ml
   Copyright 2017 Inria
   author: Damien Doligez
*)

open Printf

type step =
  | Read of string
  | Cache
  | Solve of int * int
  | Install of { stored : bool; total : int; cur : int; cur_pack : string }

type t = {
  mutable pass : int;
  mutable ocaml : string;
  mutable pack_done : int;
  mutable pack_total : int;
  mutable pack_cur : string;
  mutable step : step;
}

let cur = {
  pass = 0;
  ocaml = "";
  pack_done = 0;
  pack_total = 0;
  pack_cur = "";
  step = Read "";
}


let show ~sandbox () =
  let stopfile = Filename.concat sandbox "stop" in
  if Sys.file_exists stopfile then begin
    (try Sys.remove stopfile with _ -> ());
    Log.log "STOPPED BY USER\n";
    Log.status "\nSTOPPED BY USER\n";
    Pervasives.exit 10;
  end;
  let s1 =
    sprintf "%d %d/%d %s %s "
      cur.pass cur.pack_done cur.pack_total cur.pack_cur cur.ocaml
  in
  let s2 =
    match cur.step with
    | Read s -> sprintf "Read %s" s
    | Cache -> "Cache"
    | Solve (n, len) -> sprintf "Solve %d [%d]" n len
    | Install { stored = true; cur; total; _ } ->
       sprintf "Checkout %d/%d" cur total
    | Install { stored = false; cur; total; cur_pack } ->
       sprintf "Inst %d/%d %s" cur total cur_pack
  in
  let s = s1 ^ s2 in
  let len = String.length s in
  let line_length = 78 in
  let s =
    if len <= line_length then
      s ^ (String.make (line_length - len) ' ')
    else
      sprintf "%s##%s" (String.sub s 0 (line_length - 12))
        (String.sub s (String.length s - 10) 10)
  in
  Log.status "\n%s" s

let show_result c = Log.status "%c" c

let message m = Log.status "%s" m

let printf fmt (* args *) = Log.status fmt (* args *)
