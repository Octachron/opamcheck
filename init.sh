#!/usr/bin/bash
opam install minisat opam-file-format
cd sandbox
git clone https://github.com/ocaml/opam-repository
cd opam-repository/packages
git clone https://github.com/ocaml/ocaml-beta-repository.git
cd ../..
ln -s /usr/bin/curl bin/realcurl
make
ln -s _build/default/src/opamcheck.exe opamcheck
