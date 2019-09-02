#!/usr/bin/bash
cd sandbox
ls -la
git clone https://github.com/ocaml/opam-repository
cd opam-repository/packages
git clone https://github.com/ocaml/ocaml-beta-repository.git
cd ../..
ln -s /usr/bin/curl bin/realcurl
ln -s _build/default/src/opamcheck.exe opamcheck
