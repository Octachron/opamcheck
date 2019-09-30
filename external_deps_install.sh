opam update
for i in $(opam list -a --columns=name | tail -n+3 )
do
	echo "installing $i";
	opam depext --yes $i;
done;
