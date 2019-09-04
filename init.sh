#!/usr/bin/bash
mkdir log
cd sandbox
mkdir opamstate
ls -la
git clone https://github.com/ocaml/opam-repository
cd opam-repository/packages
git clone https://github.com/ocaml/ocaml-beta-repository.git
cd ../..
ln -s /usr/bin/curl bin/realcurl
