all:
	dune build src/opamcheck.exe
	cp _build/default/src/opamcheck.exe opamcheck
	dune build summary_js/summary.bc.js
	cp _build/default/summary_js/summary.bc.js summary_js.bc.js

debug:
	dune build src/opamcheck.bc

clean:
	dune clean

.PHONY: all clean
