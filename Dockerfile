from ocaml/opam2:ubuntu as STAGE_1
COPY --chown=opam ./external_deps_install.sh /
RUN bash /external_deps_install.sh

from STAGE_1 as STAGE_2
USER opam
RUN eval $(opam env) && opam install minisat opam-file-format dune js_of_ocaml-lwt

from STAGE_2 as STAGE_3
COPY --chown=opam . /app
USER opam
WORKDIR /app
Copy --chown=opam . /app
RUN eval $(opam env) && make
RUN bash init.sh as stage_3


from STAGE_3 as STAGE_4
USER opam
RUN mkdir /log
COPY --chown=opam ./params /app
COPY --chown=opam ./launch.sh /app
RUN chmod u+x launch.sh
CMD "/app/launch.sh"


