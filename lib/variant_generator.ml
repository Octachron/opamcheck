
let pr_variant_name trunk pr =
  Format.sprintf "%s+pr%d" trunk pr


let opam sandbox prn ppf = Format.fprintf ppf
{| opam-version: "2.0"
synopsis: "current trunk + pr %d"
maintainer: "platform@lists.ocaml.org"
depends: [
  "ocaml" {= "4.10.0" & post}
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
  src: "%s/pr%d"
}@.
|}
  prn sandbox prn


let cmd fmt =
  Format.kasprintf (fun x -> Format.eprintf "cmd: %s@." x;
                     ignore (Sys.command x)) fmt


let gen ~sandbox ~backport ~base pr =
 let cwd = Sys.getcwd () in
 let ocaml = "https://github.com/ocaml/ocaml.git" in
  cmd "git clone %s %s/pr%d" ocaml sandbox pr;
  Sys.chdir (Filename.concat sandbox ("pr" ^ string_of_int pr));
  cmd "git fetch origin pull/%d/head:pr%d" pr pr;
  if not backport then
    cmd "git checkout pr%d" pr
  else begin
    cmd "git checkout %s" base;
    cmd "git checkout -b %s+pr%d" base pr;
    cmd {|git cherry-pick $(git merge-base trunk pr%d)..$(git log -n 1 --pretty=format:"%%H" pr%d)|} pr pr
  end;
  Sys.chdir cwd

let install_opam_file base_trunk sandbox pr =
  let cwd = Sys.getcwd () in
  let () =
    Sys.chdir
    @@ String.concat Filename.dir_sep
      [sandbox; "opam-repository"; "packages"; "ocaml-variants" ] in
  let loc = "ocaml-variants." ^ pr_variant_name base_trunk pr in
  let () = Unix.mkdir loc 0o770 in
  let opam_file = Filename.concat loc "opam" in
  let f = open_out opam_file in
  let ff = Format.formatter_of_out_channel f in
  opam sandbox pr ff;
  close_out f;
  cmd "git add %s" opam_file;
  cmd {|git commit -m "trunk + pr%d"|} pr;
  Sys.chdir cwd

let for_pr ~base ~sandbox ~backport pr =
  let () = gen ~sandbox ~base ~backport pr in
  install_opam_file base sandbox pr
