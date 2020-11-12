# ��������� jenkins � docker ���������� �� ubuntu18.04 wsl2 windows10

`service docker start` ��������� docker    
`docker network create jenkins` ������������� �������� ����        

�������� ���� - ��� ���������� ���������� ������, ������� �������������� ������ ����� ���������� ����.
��� �������� Docker, �������� ���� ���������� ����������� ����, ������� ��������� �����������, 
������������ � ����� � ��� �� �������� ����, ������������ �������, 
����������� �������� �� �����������, ������� �� ���������� � ���� ���� �����. 
������� ����� Docker ������������� ������������� ������� �� ������� ����������, 
����� ���������� � ������ ����� ����� �� ����� �������� ����������������� ���� � ������.
������ �� �������� �������� ���� � �� ���������� https://docs.docker.com/network/bridge/

��� �� ��������� ������� Docker ������ ����� Jenkins, ��������� � ��������� docker:dind ����� Docker, 
��������� ��������� ������: https: //docs.docker.com/engine/reference/run/ [ docker run] �������:
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

  `--name jenkins-docker` ������ ��� ���������� (�������������)    
  `--rm` ������������� ������� ��������� docker (��������� ������ Docker) ��� ��� ����������.(�������������)     
  `--detach` ��������� ��������� Docker � ������� ������.(�������������)    
  `--privileged` ������ Docker � Docker � ��������� ����� ������� ������������������ ������� ��� ���������� ������.(�������������)    
  `--network jenkins` ��� ������������� ����, ��������� �� ���������� ����.
  `--network-alias docker` ������ Docker � ���������� Docker ��������� � �������� ����� ����� docker � jenkins����.
  `--env DOCKER_TLS_CERTDIR=/certs` �������� ������������� TLS �� ������� Docker. ��� ���������� ����� ��������� �������� ���������, � ������� ����������� ����������� Docker TLS.��� ���������� ��������� �� �������� �������� ���� � ������ ������ �������� / �������� � ������������
  `--volume jenkins-docker-certs:/certs/client` ������������ /certs/client������� ������ ���������� � ����� Docker � ������, jenkins-docker-certs��������� ����.
  `--volume jenkins-data:/var/jenkins_home` ������������ /var/jenkins_home������� ������ ���������� � ����� Docker � ������ jenkins-data. ��� �������� ������ ����������� Docker, ����������� ������� Docker ����� ���������� Docker, ����������� ������ �� Jenkins.
  `--publish 2376:2376` ������������� ������ � ����� ������ Docker �� ����-������. ��� ������� ��� ���������� docker������ �� ����-������ ��� ���������� ���� ���������� ������� Docker.
  `docker:dind` ��� ����� ����� ���� �������� ����� �������� � ������� �������: docker image pull docker:dind.
---
������� dockerfile � ����������

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
`mkdir dockerfiles` ������� �������
`cd dockerfiles` ���������
`touch Dockerfile` ������� ����� ����
`vi Dockerfile` �������������� ��� � �������� ������� � ������� ��������� vi
�������� ����� ����� ������� ��������� vi ��� �����������: `i` -��������������, `:wq` - ��������� � ����� 
� ��������, ��������� �������� ����� �����

![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/jenkins%20images_done.png)

��������� myjenkins-blueocean:1.1 ����� � �������� ���������� � Docker.

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
  `--name jenkins-blueocean \` ( ������������� )������ ��� ���������� Docker    	
  `--rm \`( ������������� ) ������������� ������� ��������� Docker ��� ��� ����������.    
  `--detach \` ( ������������� ) ��������� ������� ��������� � ������� ������� ������� ������������� ����������.    
 ���� �� �� ������� ���� ��������, �� ������� ������ Docker ��� ����� ���������� ��������� � ���� ���������.    
  `--network jenkins \` ���������� ���� ��������� � jenkins����, ������������ �� ���������� ����.    
  `--env DOCKER_HOST=tcp://docker:2376 \` ���������� ���������� ��������� docker    
  `--env DOCKER_CERT_PATH=/certs/client \`    
  `--env DOCKER_TLS_VERIFY=1 \`    
  `--publish 8080:8080 \` ������������ (�. �. ����������) ���� 8080 �������� ���������� � ������ 8080 �� ����-������.    
������ ����� ������������ ���� �� �����, � ��������� - ���� ����������. �������������, ���� �� ������� -p 49000:8080��� �����,    
�� ������ �������� ������ � Jenkins �� ����� ����-���������� ����� ���� 49000.    
  `--publish 50000:50000 \` ���� ������.( ������������� ) ������������ ���� 50000 �������� ���������� � ������ 50000 �� ����-������.    
��� ���������� ������ � ��� ������, ���� �� ��������� ���� ��� ��������� �������� ������� Jenkins �� ������ �������    
  `--volume jenkins-data:/var/jenkins_home \` var/jenkins_home������� ���������� � jenkins������������ � $HOME �������� �� ����� ��������� ����������,    
������� ������ �������� /Users/<your-username>/jenkins��� /home/<your-username>/jenkins. �������� ��������, ��� ���� �� �������� �������� ��� ���    
������� ��� �����, ��� �� docker:dind���������� ���� ���������� ��������, ����� �� �������������� �����.    
  `--volume jenkins-docker-certs:/certs/client:ro` ������������ /certs/client������� � ����� ��������� jenkins-docker-certs�����. ��� ������ ���������� TLS-�����������, ����������� ��� ����������� � ������ Docker, ���������� �� ����, ���������� DOCKER_CERT_PATH���������� �����.`
  `myjenkins-blueocean:1.1` ��� ������ Docker, ������� �� ������� �� ���������� ����.    

![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/docker_cont_run.png)
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/docker_images.jpg)

`docker logs 4db86b674ed9` ������� ���� ������� ���������� ��� �� ����� ������ ������? ��� ������� jenkins � ��������

��������� ������� ��������� � �������� ������  http://localhost:8080/
������ ������ ��������� �������� `docker log ID_cont` �������� ��� �� ���������, ID ��� id ����������� ����������
��������� �������, 
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/start_jenkins.png)
������ ������������. ����������.
![alt text](https://github.com/andy-ml/dev_ops/blob/main/lab-2/jenkins_start_done.jpg)

---
������� docker 
`docker exec -it ID_cont bash` ������ � ���������, ���� ��� �����
`docker ps` ����������� ���������� ����������, ���� -a �������� ��� ����������
`docker images` ��������� �������� image(�����) ��� Jenkins
`docker stop ID_cont` ���������� ���������
`docker rm ID_cont` ������� ���������
`docker log ID_cont` ��� �� ������� ���� ��������� jenkins � ����� ������ ������ ��� �����

---
����������� ��������� � https://www.jenkins.io/doc/book/installing/docker/    

��� �������������� �������� ������ � ����� ��� �������� ���������� ������ jenkins �� ������� ������������� ���������� ������� ����� ������������ ���������� �� ������ ����
https://hub.docker.com/_/jenkins/








