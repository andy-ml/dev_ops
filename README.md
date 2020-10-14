# 1.1 Задание. Создаем базовый box с Ubuntu 18.04 с помощью packer, выходной формат - vagrant (virtualbox)

При помощи packer создаем .box файл с образом виртуальной машины. 
 Ставим packer, VirtualBox. Создаем в текстовом редакторе файл конфигурации для packer с расширением Ubuntu64.json, собираем его по частям из репозоториев на github и читаем мануал по packer.В теле файла, что бы убедиться, что программа установки получила правильный файл(не поврежденный), нужно дополнительно указать контрольную сумму файла. Это значение вычисляется с помощью md5sum, или подобной программы или записано на сайте (уже посчитано и указано там где скачиваешь этот файл), оно(число) должно соответствовать указываемому файлу, иначе программа установки не будет использовать данный файл. 
так же создаем в текстовом редакторе файл preseed.cfg -  набор команд для установки Ubuntu таких как, например, нажатие клавиш ввод при загрузке ОС или выбор языка. И создаем в текстовом редакторе файл postinstall.sh - скрипт для  обновления и установки программ после установки ОС.

В нем(файле .json) написано, что мы берем стандартный образ Ubuntu (ключ iso_url), инсталлируем его, используя набор команд из preseed.cfg, а потом выполняем внутри скрипт postinstall.sh.

Preseed.cfg файл — это простой текстовый файл, в котором каждая строка содержит ответ на один вопрос (Ubuntu)conf. 
 
Строка разбита на четыре поля, разделённых между собой пробельными символами (пробелами или символами табуляции), например d-i mirror/suite string stable:
* первое поле — это «владелец» вопроса; «d-i» используется для вопросов, относящихся к установщику, но это также может быть имя пакета для вопросов, относящихся к пакетам Ubuntu;
* второе поле — это идентификатор вопроса;
* третье — тип вопроса;
* четвёртое -  и последнее поле содержит значение ответа. Заметьте, что оно должно быть отделено от третьего поля одним пробелом; если пробелов больше одного, последующие пробелы будут считаться частью значения.

 Простейший путь написать preseed-файл — установить систему вручную. После этого debconf-get-selections --installer предоставит ответы, относящиеся к установщику. Ответы о других пакетах могут быть получены с помощью (для дебиан) debconf-get-selections. Однако более правильным решением будет написать preseed-файл вручную, руководствуясь примером и справочной документацией: при таком подходе пресидингу подвергнутся только вопросы, для которых следует изменить значение ответа по умолчанию;
 
 

---

Cобираем все в одну папку, lab-1.1  packer.exe, postinstall.sh, preseed.cfg, ubuntu64.json это все делаю в ОС Windows команды ввожу в PowerShell
проверяем packerом ( возможно будет нужно, а возможно нет, но лучше запомнить что во вкладке "изменение системных переменных сред " - "переменные среды"
-"системные переменные" строка path должен быть прописан путь для packer) набираем команду проверки файла .json, В PowerShell находясь в папке lab-1.1

`packer.exe validate ubuntu64.json`

Если все хорошо то будет получено сообщение как на картинке.

![alt text](https://github.com/andy-ml/dev_ops/blob/main/imj%20validate-build.png)


Находять в катологе с файлом .json, запускаем packer build и ждем пока  ОС установится. При условии что ошибок не было, собираем box командой

'''
`packer build ubuntu64.json`

'''
В результате получим файл с расширением .box в папке lab-1.1 и папку packer_cachen c .iso файлами.

![alt text](https://github.com/andy-ml/dev_ops/blob/main/finished%20build.png)
  
 



