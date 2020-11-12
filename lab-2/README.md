# Установка jenkins в docker контейнере на ubuntu18.04 wsl2 windows10

`service docker start` запускаем docker    
`docker network create jenkins` устанавливаем мостовую сеть        

Мостовая сеть - это устройство канального уровня, которое перенаправляет трафик между сегментами сети.
Что касается Docker, мостовая сеть использует программный мост, который позволяет контейнерам, 
подключенным к одной и той же мостовой сети, обмениваться данными, 
обеспечивая изоляцию от контейнеров, которые не подключены к этой сети моста. 
Драйвер моста Docker автоматически устанавливает правила на главном компьютере, 
чтобы контейнеры в разных сетях моста не могли напрямую взаимодействовать друг с другом.
ссылка на описание мостовой сети и ее назначение https://docs.docker.com/network/bridge/

Что бы выполнять команды Docker внутри узлов Jenkins, загрузите и запустите docker:dind образ Docker, 
используя следующую ссылку: https: //docs.docker.com/engine/reference/run/ [ docker run] команда:
```
docker run \
  --name jenkins-docker \ 
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind

```

  `--name jenkins-docker` задаем имя контейнера (необязательно)    
  `--rm` автоматически удаляем контейнер docker (экземпляр образа Docker) при его завершении.(необязательно)     
  `--detach` Запускает контейнер Docker в фоновом режиме.(необязательно)    
  `--privileged` Запуск Docker в Docker в настоящее время требует привилегированного доступа для правильной работы.(необязательно)    
  `--network jenkins` Это соответствует сети, созданной на предыдущем шаге.
  `--network-alias docker` Делает Docker в контейнере Docker доступным в качестве имени хоста docker в jenkinsсети.
  `--env DOCKER_TLS_CERTDIR=/certs` Включает использование TLS на сервере Docker. Эта переменная среды управляет корневым каталогом, в котором управляются сертификаты Docker TLS.При правильной настройке он позволит общаться друг с другом только клиентам / серверам с сертификатом
  `--volume jenkins-docker-certs:/certs/client` Сопоставляет /certs/clientкаталог внутри контейнера с томом Docker с именем, jenkins-docker-certsсозданным выше.
  `--volume jenkins-data:/var/jenkins_home` Сопоставляет /var/jenkins_homeкаталог внутри контейнера с томом Docker с именем jenkins-data. Это позволит другим контейнерам Docker, управляемым демоном Docker этого контейнера Docker, монтировать данные из Jenkins.
  `--publish 2376:2376` Предоставляет доступ к порту демона Docker на хост-машине. Это полезно для выполнения dockerкоманд на хост-машине для управления этим внутренним демоном Docker.
  `docker:dind` Это образ может быть загружен перед запуском с помощью команды: docker image pull docker:dind.
---
Создаем dockerfile с содержимым

```
FROM jenkins/jenkins:2.249.3-slim
USER root
RUN apt-get update && apt-get install -y apt-transport-https \
       ca-certificates curl gnupg2 \
       software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins blueocean:1.24.3

```
`mkdir dockerfiles` создаем каталог
`cd dockerfiles` переходим
`touch Dockerfile` создаем докер файл
`vi Dockerfile` Отредактируйте его и добавьте команды с помощью редактора vi
отдельно нужно занть команды редактора vi для напоминания: `i` -редактирование, `:wq` - сохранить и выйти 
и запустим, результат созданый образ докер

![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/jenkins%20images_done.png)

Запускаем myjenkins-blueocean:1.1 образ в качестве контейнера в Docker.

```
docker run \
  --name jenkins-blueocean \
  --rm \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:1.1 
```
  `docker run \`    
  `--name jenkins-blueocean \` ( Необязательно )Задает имя контейнера Docker    	
  `--rm \`( Необязательно ) Автоматически удаляет контейнер Docker при его завершении.    
  `--detach \` ( Необязательно ) Запускает текущий контейнер в фоновом режимеи выводит идентификатор контейнера.    
 Если вы не укажете этот параметр, то текущий журнал Docker для этого контейнера выводится в окне терминала.    
  `--network jenkins \` Подключает этот контейнер к jenkinsсети, определенной на предыдущем шаге.    
  `--env DOCKER_HOST=tcp://docker:2376 \` Определяет переменные окружения docker    
  `--env DOCKER_CERT_PATH=/certs/client \`    
  `--env DOCKER_TLS_VERIFY=1 \`    
  `--publish 8080:8080 \` Сопоставляет (т. Е. «Публикует») порт 8080 текущего контейнера с портом 8080 на хост-машине.    
Первое число представляет порт на хосте, а последнее - порт контейнера. Следовательно, если вы указали -p 49000:8080эту опцию,    
вы будете получать доступ к Jenkins на вашем хост-компьютере через порт 49000.    
  `--publish 50000:50000 \` Порт агента.( Необязательно ) Сопоставляет порт 50000 текущего контейнера с портом 50000 на хост-машине.    
Это необходимо только в том случае, если вы настроили один или несколько входящих агентов Jenkins на других машинах    
  `--volume jenkins-data:/var/jenkins_home \` var/jenkins_homeкаталог контейнера с jenkinsподкаталогом в $HOME каталоге на вашем локальном компьютере,    
которым обычно является /Users/<your-username>/jenkinsили /home/<your-username>/jenkins. Обратите внимание, что если вы измените исходный том или    
каталог для этого, том из docker:dindконтейнера выше необходимо обновить, чтобы он соответствовал этому.    
  `--volume jenkins-docker-certs:/certs/client:ro` Сопоставляет /certs/clientкаталог с ранее созданным jenkins-docker-certsтомом. Это делает клиентские TLS-сертификаты, необходимые для подключения к демону Docker, доступными по пути, указанному DOCKER_CERT_PATHпеременной среды.`
  `myjenkins-blueocean:1.1` Имя образа Docker, который вы создали на предыдущем шаге.    

![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/docker_cont_run.png)
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/docker_images.jpg)

`docker logs 4db86b674ed9` выводим логи запуска контейнера что бы взять оттуда пароль? для запуска jenkins в браузере

Запускаем браузер вставляем в адресную строку  http://localhost:8080/
Вводим пароль полученый командой `docker log ID_cont` копируем его из терминала, ID это id запущенного контейнера
обновляем плагины, 
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/start_jenkins.png)
созаем пользователя. Используем.
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/jenkins_start_done.jpg)

---
команды docker 
`docker exec -it ID_cont bash` входим в контейнер, если это нужно
`docker ps` просмотреть запущенные контейнеры, флаг -a просмотр все контейнеры
`docker images` проверяем созданый image(образ) для Jenkins
`docker stop ID_cont` остановить контейнер
`docker rm ID_cont` удалить контейнер
`docker log ID_cont` что бы вывести логи установки jenkins и взять оттуда пароль для входа

---
Использовал материалы с https://www.jenkins.io/doc/book/installing/docker/    

При использованиии готового образа с докер хаб качается устаревшая версия jenkins на которую проблематично установить плагины лучше использовать инструкцию по ссылке выше
https://hub.docker.com/_/jenkins/








