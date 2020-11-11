# 1.7.	Работа с Docker

Установку Docker производим по этому руководству        
`https://losst.ru/ustanovka-docker-na-ubuntu-16-04`    
Краткое описание    
`sudo su` переходим в root, иначе под wsl2 ubuntu18.04 появляются ошибки, которые в root не возникают     
`sudo apt update && sudo apt upgrade` обновляем систему до актуального состояния    
`sudo apt install docker.io` качаем докер    
`sudo service --status-all` смотрим наличие сервиса docker        
[+] - работает    
[-] - не работает    
[?] - не известно    

`sudo service docker start` запускаем docker    
`docker pull nginx` скачиваем образ nginx     
`mkdir nginx` этой командой  создаем папку nginx    
`docker images` проверяем наличие образа    
`docker run -d -p 8080:80 nginx` запускаем контейнер докер с проброшеным портом, Сначала надо указывается порт машины (можно указать вместе с IP), потом порт в контейнере.    
`mkdir nginx` создаем папку    
`docker run -it -v $pwd\papka\nginx\etc:/mounted  nginx /bin/bash монтируем папку    
`docker exec -it name cont bash` зайти в контейнер, если это нужно        
`docker ps` смотрим работающие контейнеры    
`docker ps -a` смотрм все запускаемые контейнеры    
`http://localhost:8080/` запускаем в браузере, должна отобразться стартовая страница nginx    
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-1.7/imj%20validate-build.png)    
`docker stop namecont` останавливаем нужный контейнер в нашем случае nginx `namecont` может быть как название контейнера, так и его id    

