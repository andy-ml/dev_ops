#!/bin/bash

SOURSE_DIR=$1
DESTINATION_DIR=$2

CONTRAST=$( diff -r "${SOURSE_DIR}" "${DESTINATION_DIR}" ) 
#как использовать данные которые выдаст эта команда
  
if  [[ ${CONTRAST} = 0 ]]; then
  #end ничего не делаем или выводим сообщение что они одинаковые
  echo "${SOURSE_DIR} equal ${DESTINATION_DIR}"
else
  echo "${SOURSE_DIR} not equal ${DESTINATION_DIR}"
  SOURSE_DIR_SIZE=$( du -d 1 | tail -n 1 | awk '{print $1}' | tr -d 'G' ) 
  # узнаем размер директории и всего что внутри? 
  # du отображает размер дискового пространства, занятого файлами или каталогами
  # -d Выводит общий размер только до N-го уровня (включительно) дерева каталогов
  # tail -n 1 - выводить указанное количество строк из конца файла
  # awk '{print $1}' получить список только первого столбца, tr -d 'G' удалить знак "G"
  # таким обазом получаю число равное объему памяти занимаемой папкой SOURSE_DIR_SIZE 
  DESTINATION_DIR_SIZE=$( df -h "${DESTINATION_DIR}" ) # узнаем свободное место на диске куда будем копировать директорию. как это правильно спросить df -h /home
    
  if [[ "${SOURSE_DIR_SIZE}" > "${DESTINATION_DIR_SIZE}" ]]; then 
    read -p "Are you sure copy ${SOURSE_DIR}?" -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      cp -r -p "${SOURSE_DIR}" "${DESTINATION_DIR}" #~/
      # exit 1
    else
      # exit
     # echo "warning! directory $2 is greater than directory $1" 
    fi
   else  
   # echo "warning! directory $2 is greater than directory $1"
  fi

fi
