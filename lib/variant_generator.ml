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
  git: "%s/pr%d"
}@.
|}
  prn sandbox prn


let gen sandbox pr =
  let cmd fmt = Format.kasprintf (fun x -> ignore (Sys.command x)) fmt in
  cmd "git clone github.com/ocaml/ocaml.git %s/pr%d" sandbox pr;
  cmd "cd %s/pr%d" sandbox pr;
  cmd "git fetch origin pull/%d/head:pr%d" pr pr;
  cmd "git checkout pr%d" pr

let install_opam_file ver sandbox pr =
  let loc =
    String.concat Filename.dir_sep
      [sandbox; "opam-repository"; "packages"; "ocaml-variants";
       "ocaml-variants-" ^ ver ^"+pr" ^ string_of_int pr ] in
  let f = open_out loc in
  let ff = Format.formatter_of_out_channel f in
  opam sandbox pr ff;
  close_out f

let for_pr trunk sandbox pr =
  let () = gen sandbox pr in
  install_opam_file trunk sandbox pr
