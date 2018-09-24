(* sandbox.mli -- call OPAM in a controlled environment
   Copyright 2017 Inria
   author: Damien Doligez
*)

type result =
  | OK
  | Failed of (string * string) list

val play_solution : sandbox:string -> (string * string) list -> result
(** Call opam to install the elements of the list one by one. Whenever
    possible, use cached state instead of doing the installation.
*)

val get_tag : (string * string) list -> string * string
(** [let (tag, packs) = get_tag packl]
    [packl] is a list of packages, [tag] is the git tag for this
    configuration, and [packs] is the list of packages as a single string
*)
