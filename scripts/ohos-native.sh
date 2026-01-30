PROJECT_DIR="$( cd "$( dirname "$0"  )" && pwd  )/.."
OHOS_PATH=native/jmbackend/platforms/ohos
cd $PROJECT_DIR/$OHOS_PATH
make
cd $PROJECT_DIR
rsync -av --exclude oh-package.json5  $OHOS_PATH/dist/ ohos/entry/libs/