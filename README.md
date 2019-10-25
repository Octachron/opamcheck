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

## Running with docker

Another option to run opamcheck is to use the provided Dockerfile:

  * build the docker image with

```
docker build -t opamcheck:preimage -f Dockerfile_preimage
docker build -t opamcheck .
```

    The first command takes a lot of time to install all external deps

  * run with

```
docker run -v logdir:/app/log --name opamcheck_4.09 -it opamcheck run 4.07.0 4.08.1 4.09.0

```

where logdir is the name of docker volume where the logs and summary will be stored.
The list `4.07.0 4.08.1 4.09.0` is the list of compiler being tested. The last one
should be the newest one.


  * Current status is then displayed at /var/lib/docker/volumes/logdir/_data/status
   It can be displayed with:

```
sudo tail -f /var/lib/docker/volumes/logdir/_data/status
```

### PR and branch mode
If you want to test a specific PR against trunk, the `run` command above can be updated to:


```
docker run -v prN:/app/log --name opamcheck_prN -it opamcheck prmode -pr N 4.10.0+trunk
```

If the PR was made against 4.10.0+trunk.
Note that if you run a PR against a non-trunk compiler
```
docker run -v prN:/app/log --name opamcheck_prN -it opamcheck prmode -pr N 4.07.1
```
opamcheck will try to rebase the PR on the corresponding version of the compiler (i.e. 4.07.1
in this example).

If you would rather test a branch on a distinct repository, you can run

```
docker run -v branch:/app/log --name opamcheck_prN -it opamcheck prmode -branch="https://somewhere./name.git,branch" 4.07.1
```
