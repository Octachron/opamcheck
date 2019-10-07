opam update
sudo apt update

install () {
sudo DEBIAN_FRONTEND=noninteractive apt install -y -q $1
}

query_and_install () {
  l="$(opam list --readonly --external  --resolve=$1)"
  if test -z "$l"
  then
    echo No dependencies
  else
	echo deps $l
        install $l
  fi
}

for i in $(opam list -a --columns=name | tail -n+3 )
do
	echo installing $i
	query_and_install $i
done;
