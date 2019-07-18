open Js_of_ocaml

let table = Dom_html.getElementById "opamcheck_table"
let root = table##.parentNode


let (>>=) = Option.bind
let (>>|) x f = Option.map f x
let ( ** ) x y  = Option.bind x ( fun x -> Option.map (fun y -> x, y ) y)

let opt = Js.Opt.to_option
let optdef = Js.Optdef.to_option

let rows = opt (table##.childNodes##item 1) >>| fun x -> x##.childNodes

type time = New | Old

type status = Fail | Depfail | Uninstall | Unknown | Ok
type full_status = { time: time; status:status }

type row = { name:string; weight:int; status: full_status; node:Dom.node Js.t }




let list_after k (cl: _ Dom.nodeList Js.t) =
  let rec ext acc k n = if n = k then acc else
      let acc =
        Option.value (cl##item n |> opt >>| fun it -> it :: acc) ~default:acc in
      ext acc k (n-1)  in
  ext [] k (cl##.length-1)

let debug s =
  Format.kasprintf (fun s ->
      Dom_html.window##alert(Js.string s)
    ) s

let to_list x =
  let l = list_after (-1) x in
  l

let extract_name (name: Dom.node Js.t) =
  let txt = opt (name##.firstChild) in
  txt >>= fun x -> opt (x##.nodeValue) >>| Js.to_string


let extract_weight (w: Dom.node Js.t) =
  let txt = w##.firstChild in
  opt txt >>= (fun x -> opt (x##.nodeValue) ) >>| Js.to_string >>| int_of_string

let extract_status (r: Dom.node Js.t) =
  match Dom.nodeType r with
  | Dom.Element e ->
    let he = Dom_html.element e in
    let cl =he##.classList in
    optdef (cl ##item 0) >>= (fun x -> match Js.to_string x with
        | "ok" -> Some {time=Old; status=Ok}
        | "uninst" -> Some {time=Old; status=Uninstall}
        | "new_uninst" -> Some {time=New; status = Uninstall}
        | "dep_fail" -> Some {status=Depfail; time=Old}
        | "new_dep_fail" -> Some {status=Depfail; time=New}
        | "new_fail" -> Some {status=Fail; time=New}
        | "old_fail" -> Some {status=Fail; time=Old}
        | "unknown" -> Some {status=Unknown; time=New}
        | s -> debug "Unknown status:%s" s; None
      )
  | _ -> debug "status: Non element %s" (Js.to_string r##.nodeName); None

let filter_row (r: Dom.node Js.t) = r##.nodeName = Js.string "TR"


let filter_col (r: Dom.node Js.t) = r##.nodeName <> Js.string "TXT"


let pp_time ppf = function
  | New -> Format.fprintf ppf "new"
  | Old -> Format.fprintf ppf "old"

let pp_st ppf = function
  | Fail -> Format.fprintf ppf "fail"
  | Depfail -> Format.fprintf ppf "dep fail"
  | Uninstall -> Format.fprintf ppf "uninstallable"
  | Unknown -> Format.fprintf ppf "unknown"
  | Ok -> Format.fprintf ppf "ok"

let pp_status ppf s =
  Format.fprintf ppf "%a %a" pp_time s.time pp_st s.status

let get_row (node:Dom.node Js.t) =
  let childs = node##.childNodes in
(*  debug "row: %d childs" childs##.length ;*)
  opt (childs##item 0) >>= extract_name >>= fun name ->
  opt (childs##item 1) >>= extract_weight >>= fun w ->
  opt (childs##item 3) >>= extract_status >>| fun st ->
  (*let versions = List.filter filter_col @@ list_after 1 childs  in *)
(*  debug "%s %d, status: %a" name w pp_status st; *)
  {name; weight=w; status=st; node}


let int_of_status = function
  | Ok -> 0
  | Fail -> 1
  | Depfail -> 2
  | Uninstall -> 3
  | Unknown -> 4

let sts = [Fail; Depfail; Uninstall; Unknown; Ok ]

let nstatus = 1 + List.fold_left (fun m x -> max m  (int_of_status x)) 0 sts


let (.%()) hist k = hist.(int_of_status k)
let (.%()<-) hist k x = hist.(int_of_status k) <- x

let register_row hist row =
  if row.status.time = New then
    let st = row.status.status in
    hist.%(st) <- hist.%(st)+1


let pp_hist ppf hist =
  List.iter (fun st -> Format.fprintf ppf "%a:%d@ " pp_st st hist.%(st) ) sts

let hist = Array.make nstatus 0



let build_hist hist =
  let ul = Dom_html.createUl Dom_html.document in
  let add st =
    let li = Dom_html.createLi Dom_html.document in
    li##.textContent := Js.Opt.return(Js.string (Format.asprintf "%a:%d" pp_st st hist.%(st)));
    Dom.appendChild ul li in
  List.iter add sts;
  Option.iter (fun (root:Dom.node Js.t) ->
      Dom.insertBefore root ul (Js.Opt.return table)
    )
    (opt root)


let build_table sort rows =
  let l = List.sort sort rows in
  let new_table = Dom_html.(createTable document) in
  let add x =
    Dom.appendChild new_table x.node in
  let () = List.iter add l in
  Option.iter (fun root ->
      Option.iter
      (Dom.replaceChild root new_table)
      (opt root##.firstChild)
    )
    (opt root)


let ls =
  (rows >>| to_list) |> Option.value ~default:[]
  |> List.filter filter_row
  |> List.map get_row
  |> List.fold_left (fun acc x ->
      Option.value ~default:acc (x >>| fun x -> x::acc)) []

let () =
  List.iter (register_row hist) ls;
  build_hist hist;
  build_table (fun x y -> compare x.name y.name) ls
