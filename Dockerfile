
from opamcheck:preimage as STAGE_2
RUN sudo apt-get update && sudo apt-get install -y \
  m4
USER opam
RUN eval $(opam env) && opam update && opam install minisat opam-file-format dune js_of_ocaml-lwt

from STAGE_2 as STAGE_3
COPY --chown=opam sandbox /app/sandbox
COPY --chown=opam init.sh /app/
COPY --chown=opam opam.lock /app/
USER opam
WORKDIR /app
RUN bash init.sh as stage_3
VOLUME ["/app/log"]

from STAGE_3 as STAGE_4
USER opam
WORKDIR /app
COPY --chown=opam lib /app/lib
COPY --chown=opam src /app/src
COPY --chown=opam dune /app/
COPY --chown=opam dune-project /app/
COPY --chown=opam Makefile /app/

RUN eval $(opam env) && make
RUN cp _build/default/src/opamcheck.exe opamcheck

from STAGE_3 as STAGE_5
USER opam
COPY --from=STAGE_4 --chown=opam /app/opamcheck /app/
COPY --chown=opam ./launch.sh /app
RUN chmod u+x launch.sh
ENTRYPOINT ["/app/launch.sh"]
