all: opamcheck summary_js.bc.js

opamcheck:
	dune build src/opamcheck.exe
	cp _build/default/src/opamcheck.exe opamcheck

summary_js.bc.js:
	dune build summary_js/summary.bc.js
	cp _build/default/summary_js/summary.bc.js summary_js.bc.js

debug:
	dune build src/opamcheck.bc

clean:
	dune clean

.PHONY: all clean

.PHONY: docker-preimage
docker-preimage:
	docker build -t opamcheck:preimage -f Dockerfile_preimage .

.PHONY: docker
docker: docker-preimage
	docker build -t opamcheck .
