#!/bin/sh

GLFTPD_DIR="/mnt/glftpd"
TRUNK_DIR="$GLFTPD_DIR/trunk"
PZSNG_DIR="$TRUNK_DIR/pzs-ng"
ZSCONFIG_SRC="$TRUNK_DIR/pzs-ng/zipscript/conf/zsconfig.h"
ZSCONFIG_BACKUP="$GLFTPD_DIR/zsconfig.h.bak"
ZSCONFIG_DEST="$PZSNG_DIR/zipscript/conf/zsconfig.h"

show_loading() {
  printf "["
  for i in $(seq 1 50); do
    printf "#"
    sleep 0.01
  done
  printf "]\n"
}

[ ! -d "$GLFTPD_DIR" ] && { echo "Error: $GLFTPD_DIR not found"; exit 1; }
[ ! -d "$TRUNK_DIR" ] && { echo "Error: $TRUNK_DIR not found"; exit 1; }
[ ! -f "$ZSCONFIG_SRC" ] && { echo "Error: $ZSCONFIG_SRC not found"; exit 1; }

echo "Creating backup of zsconfig.h"
cp "$ZSCONFIG_SRC" "$ZSCONFIG_BACKUP" || { echo "Failed to create backup"; exit 1; }

cd "$TRUNK_DIR" || { echo "Failed to change to $TRUNK_DIR"; exit 1; }

[ -d "$PZSNG_DIR" ] && { echo "Removing existing $PZSNG_DIR"; rm -rf "$PZSNG_DIR"; }

echo "Cloning latest pzs-ng repository"
show_loading
git clone --depth 1 https://github.com/glftpd/pzs-ng.git "$PZSNG_DIR" || { echo "Failed to clone repository"; exit 1; }

echo "Restoring zsconfig.h"
cp "$ZSCONFIG_BACKUP" "$ZSCONFIG_DEST" || { echo "Failed to restore zsconfig.h"; exit 1; }

echo "Installing zipscript"
cd "$PZSNG_DIR" || { echo "Failed to change to $PZSNG_DIR"; exit 1; }
show_loading
./configure --with-install-path="$GLFTPD_DIR" --silent || { echo "Configure failed"; exit 1; }
make -j$(nproc) || { echo "Make failed"; exit 1; }
make install || { echo "Make install failed"; exit 1; }

cat << 'EOF'
________
\______ \   ____   ____   ____ 
 |    |  \ /  _ \ /    \_/ __ \ 
 |    `   (  <_> )   |  \  ___/ 
/_______  /\____/|___|  /\___  > 
        \/            \/     \/ 
EOF

echo "Installation completed"