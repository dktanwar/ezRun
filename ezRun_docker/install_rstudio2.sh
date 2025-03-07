#!/bin/bash

ln -s /root/local/openssl/lib/libssl.so.1.1 /usr/lib/libssl.so.1.1
ldconfig
export LD_LIBRARY_PATH=/root/openssl-1.1.1l/libssl.so.1.1:$LD_LIBRARY_PATH

wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2023.12.0-369-amd64.deb
echo 'y' | gdebi rstudio-server-2023.12.0-369-amd64.deb

ln -fs /usr/lib/rstudio-server/bin/rstudio-server /usr/local/bin
ln -fs /usr/lib/rstudio-server/bin/rserver /usr/local/bin

# https://github.com/rocker-org/rocker-versioned2/issues/137
rm -f /var/lib/rstudio-server/secure-cookie-key

## RStudio wants an /etc/R, will populate from $R_HOME/etc
mkdir -p /etc/R

## Make RStudio compatible with case when R is built from source
## (and thus is at /usr/local/bin/R), because RStudio doesn't obey
## path if a user apt-get installs a package
R_BIN=$(which R)
echo "rsession-which-r=${R_BIN}" >/etc/rstudio/rserver.conf
## use more robust file locking to avoid errors when using shared volumes:
echo "lock-type=advisory" >/etc/rstudio/file-locks

## Prepare optional configuration file to disable authentication
## To de-activate authentication, `disable_auth_rserver.conf` script
## will just need to be overwrite /etc/rstudio/rserver.conf.
## This is triggered by an env var in the user config
cp /etc/rstudio/rserver.conf /etc/rstudio/disable_auth_rserver.conf
echo "auth-none=1" >>/etc/rstudio/disable_auth_rserver.conf

## Set up RStudio init scripts
mkdir -p /etc/services.d/rstudio
cat <<"EOF" >/etc/services.d/rstudio/run
#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
for line in $( cat /etc/environment ) ; do export $line > /dev/null; done
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
EOF

cat <<EOF >/etc/services.d/rstudio/finish
#!/bin/bash
/usr/lib/rstudio-server/bin/rstudio-server stop
EOF

# If CUDA enabled, make sure RStudio knows (config_cuda_R.sh handles this anyway)
if [ -n "$CUDA_HOME" ]; then
    sed -i '/^rsession-ld-library-path/d' /etc/rstudio/rserver.conf
    echo "rsession-ld-library-path=$LD_LIBRARY_PATH" >>/etc/rstudio/rserver.conf
fi

# Log to stderr
cat <<EOF >/etc/rstudio/logging.conf
[*]
log-level=warn
logger-type=syslog
EOF

# set up default user
default_user.sh "${DEFAULT_USER}"

# install user config initiation script
#cp init_set_env.sh /etc/cont-init.d/01_set_env
cp init_userconf.sh /etc/cont-init.d/02_userconf
cp pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper

# Clean up
rm -rf /var/lib/apt/lists/*

# Check the RStudio Server
echo -e "Check the RStudio Server version...\n"

rstudio-server version

echo -e "\nInstall RStudio Server, done!"
