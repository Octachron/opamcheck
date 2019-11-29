from opamcheck:preimage as STAGE_1
COPY --chown=opam sandbox /app/sandbox
COPY --chown=opam init.sh /app/
COPY --chown=opam opam.lock /app/
USER opam
WORKDIR /app
RUN bash init.sh

from STAGE_1 as STAGE_2
USER opam
WORKDIR /app
COPY --chown=opam lib /app/lib
COPY --chown=opam src /app/src
COPY --chown=opam summary_js /app/summary_js
COPY --chown=opam dune /app/
COPY --chown=opam dune-project /app/
COPY --chown=opam Makefile /app/
RUN eval $(opam env) && opam install --yes minisat opam-file-format dune js_of_ocaml-lwt
RUN eval $(opam env) && make

from STAGE_1 as STAGE_3
USER opam
COPY --from=STAGE_2 --chown=opam /app/opamcheck /app/
COPY --from=STAGE_2 --chown=opam /app/summary_js.bc.js /app/
COPY --chown=opam ./launch.sh /app
RUN chmod u+x launch.sh
VOLUME ["/app/log"]
ENTRYPOINT ["/app/launch.sh"]
