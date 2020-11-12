#!/bin/bash

DIR_MASK="dir_XXXX"
FILE_MASK="fileXXXX"

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
    echo "Should be like: ./script.sh . 2 100 3"
fi

DIR_PATH=$1 #путь
DEPTH=$2 #глубина
MAX_FILE_SIZE=$3 #размер файла
ITERATION=$4 #количество файлов

cd ${DIR_PATH}

for (( DIR=0; DIR < ${DEPTH}; DIR++ )); do
  DIR_NAME=$(mktemp -d ${DIR_MASK})
  echo "create ${DIR_NAME}"
  cd ${DIR_NAME}

  for (( FILE = 0; FILE < ${ITERATION}; FILE++ )); do
    FILE_NAME=$(mktemp ${FILE_MASK})
    echo "create ${FILE_NAME}"
    dd if=/dev/zero of=${FILE_NAME} bs=1 count=${MAX_FILE_SIZE} > /dev/null 2>&1
  done
done