from opam2:ubuntu

WORKDIR /app
Copy . /app

RUN bash conf_install.sh

RUN adduser opamcheck
USER myuser

Run bash init.sh

CMD ["bash", "launch.sh"]
