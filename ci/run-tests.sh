#!/bin/bash
set -e

#
# test http app
#
function test_app {
  echo "# Test $1 "
  set +e
  ret=0
  timeout=180;
  test_result=1
  until [ "$timeout" -le 0 -o "$test_result" -eq 0 ] ; do
      eval $1
      test_result=$?
      echo "Wait $timeout seconds: APP coming up ($test_result)";
      (( timeout-- ))
      sleep 1
  done
  if [ "$test_result" -gt 0 ] ; then
       ret=$test_result
       echo "ERROR: APP down"
       return $ret
  fi
  set -e

  return $ret
}

echo "# $(basename $0) started"

echo "# prepare artifacts tests"
cat <<EOF > artifacts
COMPOSE_PROJECT_NAME=ci
EOF
# ci config
cp docker-compose-ci.yml docker-compose-custom.yml

echo "# clean env"
make down clean-data-dir

echo "# build image"
make build-all

echo "# up all services"
make up-all

echo "# test all services"
test_app "make test-all"

echo "# clean env"
make down clean-data-dir
