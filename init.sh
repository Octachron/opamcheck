#!/usr/bin/bash
sudo mkdir log
sudo chown opam log
sudo chown -R opam /app
cd sandbox
mkdir opamstate
git clone https://github.com/ocaml/opam-repository
cp -RT patched_packages/ opam-repository/packages/
cd opam-repository/packages
git clone https://github.com/ocaml/ocaml-beta-repository.git
cd ../..
ln -s /usr/bin/curl bin/realcurl
