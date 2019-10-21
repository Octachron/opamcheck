
type variant =
  { version: string; extensions:string list}

let pr_variant_name trunk pr =
  Format.sprintf "%s+pr%d" trunk pr

let plus ppf () = Format.fprintf ppf "+"

let pp_variant ppf {version;extensions} =
  Format.fprintf ppf "%s+%a" version
    Format.(pp_print_list ~pp_sep:plus pp_print_string) extensions


let name v = Format.asprintf "%a" pp_variant v

let where ~sandbox ~variant = Format.asprintf "%s/%a"  sandbox pp_variant variant

let dissect s = match String.split_on_char '+' s with
  | [] -> assert false
  | version :: extensions -> { version; extensions }

let is_trunk v = List.mem "trunk" v.extensions

let opam ~sandbox ~variant ppf = Format.fprintf ppf
{| opam-version: "2.0"
synopsis: "experimental OCaml branch tested by opamcheck"
maintainer: "platform@lists.ocaml.org"
depends: [
  "ocaml" {= "%s" & post}
  "base-unix" {post}
  "base-bigarray" {post}
  "base-threads" {post}
  "ocaml-beta"
]
conflict-class: "ocaml-core-compiler"
flags: compiler
setenv: CAML_LD_LIBRARY_PATH = "%%{lib}%%/stublibs"
build: [
  ["./configure" "--prefix=%%{prefix}%%"]
    {os != "openbsd" & os != "freebsd" & os != "macos"}
  [
    "./configure"
    "--prefix=%%{prefix}%%"
    "CC=cc"
    "ASPP=cc -c"
  ] {os = "openbsd" | os = "freebsd" | os = "macos"}
  [make "world"]
  [make "world.opt"]
]
install: [make "install"]
url {
  src: "%s"
}@.
|}
  variant.version (where ~sandbox ~variant)

let cmd fmt =
  Format.kasprintf (fun x -> Format.eprintf "cmd: %s@." x;
                     ignore (Sys.command x)) fmt


let gen_pr ~base ~where pr =
 let cwd = Sys.getcwd () in
 let basev = dissect base in
 let ocaml = "https://github.com/ocaml/ocaml.git" in
  cmd "git clone %s %s" ocaml where;
  Sys.chdir where;
  if is_trunk basev then
    cmd "git fetch origin pull/%d/head:pr%d" pr pr
  else
    begin
      cmd "git fetch --tags";
      cmd "git checkout %s" base;
      cmd "git checkout -b %s+pr%d" base pr;
      cmd {|git cherry-pick $(git merge-base trunk pr%d)..$(git log -n 1 --pretty=format:"%%H" pr%d)|} pr pr
    end
  ;
  Sys.chdir cwd

let gen_branch ~where ~src  =
  match String.split_on_char ',' src with
  | [src] ->
    cmd "git clone %s %s" src where
  | [src; branch] ->
    cmd "git clone --single-branch --branch %s %s %s"
      branch src where
  | _ -> raise (Invalid_argument "Opamcheck: invalid source")

let install_opam_file ~sandbox ~variant =
  let cwd = Sys.getcwd () in
  let () =
    Sys.chdir
    @@ String.concat Filename.dir_sep
      [sandbox; "opam-repository"; "packages"; "ocaml-variants" ] in
  let loc = Format.asprintf "ocaml-variants.%a" pp_variant variant in
  let () = Unix.mkdir loc 0o770 in
  let opam_file = Filename.concat loc "opam" in
  let f = open_out opam_file in
  let ff = Format.formatter_of_out_channel f in
  opam ~sandbox ~variant ff;
  close_out f;
  cmd "git add %s" opam_file;
  cmd {|git commit -m "experimental variant %a"|} pp_variant variant;
  Sys.chdir cwd

let pr_variant ~base ~pr =
  { (dissect base) with extensions = [Format.sprintf "pr%d" pr] }

let branch_variant ~src:_ ~base =
  { (dissect base) with extensions = ["experimental_branch"] }

let for_pr ~base ~sandbox pr =
  let variant = pr_variant ~base ~pr in
  let where = where ~sandbox ~variant in
  let () = gen_pr ~base ~where pr in
  install_opam_file ~sandbox ~variant;
  variant

let for_branch ~src ~sandbox ~base =
  let variant = branch_variant ~base ~src in
  let where = where ~sandbox ~variant in
  let () = gen_branch ~src ~where in
  install_opam_file ~sandbox ~variant;
  variant
