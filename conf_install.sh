for i in $(opam list -a --columns=name | grep conf-)
do
	echo "installing $i";
	opam depext --yes $i;
done;
