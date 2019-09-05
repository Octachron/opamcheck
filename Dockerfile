from ocaml/opam2:ubuntu as STAGE_1
COPY --chown=opam ./external_deps_install.sh /
RUN bash /external_deps_install.sh

#from ocaml/opam2:ubuntu as STAGE_2
from STAGE_1 as STAGE_2
RUN sudo apt-get update && sudo apt-get install -y \
  m4
USER opam
RUN eval $(opam env) && opam update && opam install minisat opam-file-format dune js_of_ocaml-lwt

from STAGE_2 as STAGE_3
COPY --chown=opam sandbox /app/
COPY --chown=opam init.sh /app/
USER opam
WORKDIR /app
RUN bash init.sh as stage_3
VOLUME ["/app/log"]

from STAGE_3 as STAGE_4
USER opam
WORKDIR /app
COPY --chown=opam lib /app/
COPY --chown=opam src /app/
COPY --chown=opam dune /app/
RUN eval $(opam env) && make
RUN cp _build/default/src/opamcheck.exe opamcheck

from STAGE_3 as STAGE_5
USER opam
COPY --from=STAGE_4 --chown=opam /app/opamcheck /app/
COPY --chown=opam ./launch.sh /app
RUN chmod u+x launch.sh
ENTRYPOINT ["/app/launch.sh"]
