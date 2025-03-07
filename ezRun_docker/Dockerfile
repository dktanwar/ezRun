FROM debian:12

ENV R_VERSION=4.3.2
ENV R_HOME=/usr/local/lib/R
ENV TZ=Etc/UTC

COPY 1_install_R.sh 1_install_R.sh

CMD ["/bin/bash"]

RUN bash 1_install_R.sh


COPY 2_install_R.sh 2_install_R.sh
RUN bash 2_install_R.sh

COPY install_s6init.sh install_s6init.sh
RUN bash install_s6init.sh

COPY 3_rstudio.sh 3_rstudio.sh
RUN bash 3_rstudio.sh

COPY default_user.sh default_user.sh
COPY init_set_env.sh init_set_env.sh
COPY init_userconf.sh init_userconf.sh
COPY pam-helper.sh pam-helper.sh

COPY install_rstudio.sh install_rstudio.sh
RUN bash install_rstudio.sh

COPY install_rstudio2.sh install_rstudio2.sh
RUN bash install_rstudio2.sh

#COPY install_pandoc.sh install_pandoc.sh
#RUN bash install_pandoc.sh

#COPY install_quarto.sh install_quarto.sh
#RUN bash install_quarto.sh

#EXPOSE 8787

#CMD ["/init"]
