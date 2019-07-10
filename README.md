The purpose of `opamcheck` is to automate the task of checking
experimental/development versions of the OCaml compilers on a bunch of
OPAM packages.

To this end, we run `opam` in a loop, trying to install all the
(available) packages one after the other.

In order to get deterministic behavior, `opam` is isolated from the
network by a sandbox, composed of:
- a clone of `opam-repository`
- a special wrapper around `curl` that caches all download results


This new version is still under construction. Its driver is an OCaml program
instead of a bunch of bash and awk scripts.

## Installation:

   After cloning the repository, you need to

   * install minisat and opam-file-format
   * clone the opam-repository in sandbox
   * clone the ocaml-beta-repository in sandbox/opam-repository/packages
   * link the system curl to sandbox/bin/realcurl
   * link the dune-built executable to opamcheck
   * launch opamcheck after setting up OPCSANDBOX and PATH, e.g.
         ./src/launch 4.03 4.06 4.09.0+beta1

   * Current status is displayed on sandbox/status, use "tail -f sandbox/status" to display it if needed.
