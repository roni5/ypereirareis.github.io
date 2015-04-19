VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

IMAGE_NAME='docker-ypereirareis'
CONTAINER_NAME="jekyll-ypereirareis"

USER="bob"
HOME_DIR="/home/$USER"
EXECUTE_AS="sudo -u bob HOME=$HOME_DIR"

log() {
  echo -e "$BLEU > $1 $NORMAL"
}

error() {
  echo -e -n "$ROUGE"
  echo " >>> ERROR - $1"
  echo -e -n "$NORMAL"
}

build() {
  docker build -t $IMAGE_NAME .

  [ $? != 0 ] && error "Docker image build failed !" && exit 100
}

npm() {
  log "NPM install"
  docker run -it --rm -v $(pwd):/app $IMAGE_NAME \
    bash -ci "$EXECUTE_AS npm install"

  [ $? != 0 ] && error "Npm install failed !" && exit 101
}

bower() {
  log "Bower install"
  docker run -it --rm -v $(pwd):/app -v /var/tmp/bower:$HOMEDIR/.bower $IMAGE_NAME \
    /bin/bash -ci "$EXECUTE_AS bower install --allow-root install \
      --config.interactive=false \
      --config.storage.cache=$HOMEDIR/.bower/cache \
      --config.storage.registry=$HOMEDIR/.bower/registry \
      --config.storage.empty=$HOMEDIR/.bower/empty \
      --config.storage.packages=$HOMEDIR/.bower/packages"

  [ $? != 0 ] && error "Bower install failed !" && exit 102
}

jkbuild() {
  log "Jekyll build"
  docker run -it --rm -v $(pwd):/app $IMAGE_NAME \
    /bin/bash -ci "$EXECUTE_AS jekyll build"

  [ $? != 0 ] && error "Jekyll build failed !" && exit 103
}

grunt() {
  log "Grunt build"
  docker run -it --rm -v $(pwd):/app $IMAGE_NAME \
    /bin/bash -ci "$EXECUTE_AS grunt"

  [ $? != 0 ] && error "Grunt build failed !" && exit 104
}

jkserve() {
  log "Jekyll serve"
  docker run -it -d --name="$CONTAINER_NAME" -p 4000:4000 -v $(pwd):/app $IMAGE_NAME \
    /bin/bash -ci "jekyll serve -H 0.0.0.0"

  [ $? != 0 ] && error "Jekyll serve failed !" && exit 105
}

install() {
  echo "Installing full application at once"
  remove
  npm
  bower
  jkbuild
  grunt
  jkserve
}

bash() {
  log "BASH"
  docker run -it --rm -v $(pwd):/app $IMAGE_NAME /bin/bash
}

stop() {
  docker stop $CONTAINER_NAME
}

start() {
  docker start $CONTAINER_NAME
}

remove() {
  log "Removing previous container $CONTAINER_NAME" && \
      docker rm -f $CONTAINER_NAME &> /dev/null || true
}

help() {
  echo "-----------------------------------------------------------------------"
  echo "                      Available commands                              -"
  echo "-----------------------------------------------------------------------"
  echo -e -n "$VERT"
  echo "   > build - To build the Docker image"
  echo "   > npm - To install NPM modules/deps"
  echo "   > bower - To install Bower/Js deps"
  echo "   > jkbuild - To build Jekyll project"
  echo "   > grunt - To run grunt task"
  echo "   > jkserve - To serve the project/blog on 127.0.0.1:4000"
  echo "   > install - To execute full install at once"
  echo "   > stop - To stop main jekyll container"
  echo "   > start - To start main jekyll container"
  echo "   > bash - Log you into container"
  echo "   > remove - Remove main jekyll container"
  echo "   > help - Display this help"
  echo -e -n "$NORMAL"
  echo "-----------------------------------------------------------------------"

}

$*