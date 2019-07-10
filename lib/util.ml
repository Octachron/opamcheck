(* util.ml
   Copyright 2017 Inria
   author: Damien Doligez
*)

module SM = Map.Make (String)

let cmp = Stdlib.compare
module StringPair = struct
  type t = string * string
  let compare = cmp
end
module SPM = Map.Make (StringPair)

module SS = Set.Make (String)

module SPS = Set.Make (StringPair)

module StringPairList = struct
  type t = (string * string) list
  let compare l1 l2 =
    let len1 = List.length l1 in
    let len2 = List.length l2 in
    if len1 > len2 then -1
    else if len1 < len2 then 1
    else cmp l2 l1
end
module SPLS = Set.Make (StringPairList)

let string_search key s =
  if key = "" then Some 0
  else if s = "" then None else begin
    let rec search_first i =
      if i >= String.length s then None
      else if s.[i] = key.[0] then check_match i 0
      else search_first (i + 1)
    and check_match i j =
      if i + j >= String.length s then None
      else if j >= String.length key then Some i
      else if s.[i + j] = key.[j] then check_match i (j + 1)
      else search_first (i + 1)
    in
    search_first 0
  end
