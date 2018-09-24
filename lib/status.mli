(* status.mli -- display current status
   Copyright 2017 Inria
   author: Damien Doligez
*)

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

val cur : t

val show : sandbox:string -> unit -> unit
val show_result : char -> unit
val message : string -> unit

val printf : ('a, unit, string, unit) format4 -> 'a
