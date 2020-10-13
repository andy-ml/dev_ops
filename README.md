#1.1 Задание
~Ставим packer, VirtualBox, vagrant~Создаем в текстовом редакторе файл конфигурации для packer с расширением Ubuntu64.json, собираем его по частям из репозоториев github
~preseed.cfg -  набор команд для установки Ubuntu? таких как, например нажатие клавиш ввод~
~postinstall.sh скрипт для  обновления и установки программ после установки ОС~
'''
{
  "provisioners": [
    {
      "type": "shell",
      "scripts": [
        "postinstall.sh"
      ],
      "override": {
        "virtualbox-iso": {
          "execute_command": "echo 'vagrant'|sudo -S sh '{{.Path}}'"
        }
      }
    }
  ],
  "builders": [
    {
      "type": "virtualbox-iso",
      "boot_command": [
        "<esc><wait>",
        "<esc><wait>",
        "<enter><wait>",
        "/install/vmlinuz noapic<wait>",
        " auto<wait>",
        " console-setup/ask_detect=false<wait>",
        " console-setup/layoutcode=us<wait>",
        " console-setup/modelcode=pc105<wait>",
        " debconf/frontend=noninteractive<wait>",
        " debian-installer=en_US.UTF-8<wait>",
		"grub-installer/bootdev=/dev/sda<wait> ",
        " fb=false<wait>",
        " initrd=/install/initrd.gz<wait>",
        " kbd-chooser/method=us<wait>",
        " keyboard-configuration/layout=USA<wait>",
        " keyboard-configuration/variant=USA<wait>",
        " locale=en_US.UTF-8<wait>",
        " netcfg/get_domain=vm<wait>",
        " netcfg/get_hostname=vagrant<wait>",
        " noapic<wait>",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
        " -- <wait>",
        "<enter><wait>"
      ],
      "boot_wait": "10s",
      "disk_size": 65536,
      "guest_os_type": "Ubuntu_64",
	  "hard_drive_interface": "sata",
      
            "iso_urls": [
            "http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.5-server-amd64.iso"
            ],
            "iso_checksum_type": "sha256",
            "iso_checksum": "8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996",
      "ssh_username": "vagrant",
      "ssh_password": "vagrant",
      "ssh_port": 22,
      "http_directory" : ".",
      "http_port_min" : 9001,
      "http_port_max" : 9001,
      "ssh_wait_timeout": "10000s",
      "shutdown_command": "echo 'shutdown -P now' > shutdown.sh; echo 'vagrant'|sudo -S sh 'shutdown.sh'",
      "guest_additions_path": "VBoxGuestAdditions_{{.Version}}.iso",
      "virtualbox_version_file": ".vbox_version",
      "vboxmanage": [
        [
          "modifyvm",
          "{{.Name}}",
          "--memory",
          "1024"
        ],
        [
          "modifyvm",
          "{{.Name}}",
          "--cpus",
          "1"
        ]
      ]
    }
  ],
  "post-processors": [
    "vagrant"
  ]
}
'''
~В нем написано, что мы берем стандартный образ Ubuntu (ключ iso_url), инсталлируем его, используя набор команд из preseed.cfg, а потом выполняем внутри скрипт postinstall.sh
Preseed-файл — это простой текстовый файл, в котором каждая строка содержит ответ на один вопрос (Ubuntu)conf. Строка разбита на четыре поля, разделённых между собой пробельными символами (пробелами или символами табуляции), например d-i mirror/suite string stable:
первое поле — это «владелец» вопроса; «d-i» используется для вопросов, относящихся к установщику, но это также может быть имя пакета для вопросов, относящихся к пакетам Ubuntu;
второе поле — это идентификатор вопроса;
третье — тип вопроса;
четвёртое -  и последнее поле содержит значение ответа. Заметьте, что оно должно быть отделено от третьего поля одним пробелом; если пробелов больше одного, последующие пробелы будут считаться частью значения.
Простейший путь написать preseed-файл — установить систему вручную. После этого debconf-get-selections --installer предоставит ответы, относящиеся к установщику. Ответы о других пакетах могут быть получены с помощью (для дебиан)debconf-get-selections. Однако более правильным решением будет написать preseed-файл вручную, руководствуясь примером и справочной документацией: при таком подходе пресидингу подвергнутся только вопросы, для которых следует изменить значение ответа по умолчанию;~
 '''
### Base system installation
d-i base-installer/kernel/override-image string linux-server

### Account setup
d-i passwd/user-fullname string vagrant
d-i passwd/username string vagrant
d-i passwd/user-password password vagrant
d-i passwd/user-password-again password vagrant
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

### Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string UTC
#d-i time/zone string Asia/Tokyo

### Partitioning
d-i partman-auto/method string lvm
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/guided_size string max
d-i partman/choose_partition select finish
d-i partman/confirm_nooverwrite boolean true

### Mirror settings
#d-i mirror/country string JP
d-i mirror/http/proxy string

### Package selection
tasksel tasksel/first multiselect standard
d-i pkgsel/update-policy select none
d-i pkgsel/include string openssh-server
d-i pkgsel/install-language-support boolean false

### Boot loader installation
d-i grub-installer/only_debian boolean true

### Finishing up the installation
d-i finish-install/reboot_in_progress note
'''
~Если используется метод initrd, то нужно убедиться, что файл с именем preseed.cfg https://github.com/heizo/packer-ubuntu-18.04/blob/master/http/preseed.cfg  лежит в корневом каталоге initrd. Программа установки автоматически проверяет наличие этого файла и загружает его.
Для других методов автоматической установки нужно указать при загрузке программе установки какой файл использовать при загрузке. Это можно сделать через параметр загрузки ядра, вручную во время загрузки или изменив файл настройки системного загрузчика (например, syslinux.cfg) и добавить параметр в конец строки append для ядра.
Если вы указываете файл ответов в настройке системного загрузчика, то можно изменить конфигурацию таким образом, чтобы не нажимать клавишу ввод для загрузки программы установки. Для syslinux это достигается установкой timeout равным 1 в файле syslinux.cfg.
Чтобы убедиться, что программа установки получила правильный файл ответов, можно дополнительно указать контрольную сумму файла. Это значение вычисляется с помощью md5sum, и если его указать, то оно должно соответствовать указываемому файлу, иначе программа установки не будет использовать данный файл.
Файл 
postinstall.sh Выполняет , обновление и установку программ в установленой ОС~
'''
# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time


# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install vim curl
apt-get clean

curl -L https://www.opscode.com/chef/install.sh | sudo bash

# Installing the virtualbox guest additions
apt-get -y install dkms
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Setup sudo to allow no-password sudo for "admin"
groupadd -r sudo
usermod -a -G sudo vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh


apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
 
'''
~Cобираем все в одну папку. Vagrant,packer, postinstall.sh, preseed.cfg, ubuntu64.json, 
проверяем packerом (помещаем в папку D:it/bin возможно нужно, а возможно нет, но лучше запомнить что во вкладке "изменение системных переменных сред " - "переменные среды"
-"системные переменные" строка path должен быть прописан путь)~
~проверка файла~
'lab-1.1\packer.exe validate lab-1.1\ubuntu64.json'
~Находять в катологе с файлом json, запускаем packer build и ждем пока скачается образ ОС и она установится. При условии что ошибок не было, собираем командой~
'\lab-1.1> packer build \lab-1.1\ubuntu64.json'
  
 



