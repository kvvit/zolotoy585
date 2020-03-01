# 585 Zolotoy Test
## Тестовое задание на знание базовых принципов работы с Linux и Docker.
Здравствуйте.
1. Предварительные действия:
- Установил vim и sudo
- Отредактировал файл /etc/sudoers для того, чтобы запускать команды с повышенными привелегиями без ввода пароля
- Установил статический ip адрес, из своей домашней приватной сети
- Создал в домашнем каталоге папку .ssh с файлом authorized_keys, скопировал в данный файл со своего компьютера содержимое файла id_rsa.pub, для того, чтобы подключаться к тестовой ВМ без пароля
2. Задания на работу с дисками:
- Установка mdadm
```bash
sudo apt install mdadm
```
- Тест двух дисков, из которых будем собирать RAID-1 (с выводом)
```bash
sudo mdadm --examine /dev/sda2 /dev/sda3
mdadm: No md superblock detected on /dev/sda2.
mdadm: No md superblock detected on /dev/sda3.
```
- Создание логического диска с RAID-1
```bash
sudo mdadm --create /dev/md0 --level=mirror --raid-devices=2 /dev/sda2 /dev/sda3
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```
- Создание volume group
```bash
sudo vgcreate vg1 /dev/md0
  Physical volume "/dev/md0" successfully created.
  Volume group "vg1" successfully created
```
- Создание lvm тома с 90% от объема volume group
```bash
sudo lvcreate -l 90%VG -n devops vg1
  Logical volume "devops" created.
```
- Форматирование нового lvm
```bash
sudo mkfs.ext4 /dev/vg1/devops 
mke2fs 1.44.5 (15-Dec-2018)
Creating filesystem with 434176 1k blocks and 108544 inodes
Filesystem UUID: 531a3e01-e02c-4b63-8198-9bce287b4f8c
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729, 204801, 221185, 401409

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
- Монтирование нового тома и вывод смонтированных систем после измененеия /etc/fstab
```bash
sudo mount -a
devops@devops:~$ df -h
Файловая система       Размер Использовано  Дост Использовано% Cмонтировано в
udev                     983M            0  983M            0% /dev
tmpfs                    200M         3,0M  197M            2% /run
/dev/mapper/vg0-root     2,6G         1,9G  510M           79% /
tmpfs                    998M            0  998M            0% /dev/shm
tmpfs                    5,0M            0  5,0M            0% /run/lock
tmpfs                    998M            0  998M            0% /sys/fs/cgroup
tmpfs                    200M            0  200M            0% /run/user/1000
/dev/mapper/vg1-devops   403M         2,3M  376M            1% /mnt/vg1/devops
```
- Измененение размера системного тома без перезагрузки (использовал pvresize, и cfdisk)
```bash
sudo pvresize /dev/sda4
  Physical volume "/dev/sda4" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
```
- Увеличение системного раздела на весь доступный размер
```bash
sudo lvresize -r -l 100%PVS /dev/vg0/root
  Size of logical volume vg0/root changed from <2,61 GiB (667 extents) to <6,79 GiB (1737 extents).
  Logical volume vg0/root successfully resized.
resize2fs 1.44.5 (15-Dec-2018)
Filesystem at /dev/mapper/vg0-root is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/mapper/vg0-root is now 1778688 (4k) blocks long.
```
- Создание swap файла (т.к. объем оперативной памяти 2Гб, решил сделать совокупный объем подкачки так же 2Гб)
```bash 
sudo fallocate -l 1,7G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
Setting up swapspace version 1, size = 1,7 GiB (1807740928 bytes)
no label, UUID=40f6822b-9c2e-4a12-9d97-441cc7ddc7e0
sudo swapon /swapfile
```
2. Задания на работу с докером и nginx и mysql
- Для того, чтобы не работать под учетной записью root, добавил пользователя devops в группу docker
- Докерфайл для сборки образа с установленным внутри php-fpm находится в /opt/docker-apps/test/php (простенький получлися, я указал директиву RUN специально одной командой, чтобы не плодить слои)
- Сам образ собран следующей командой
```bash
docker build -t deb-php-fpm:v1 .
```
- Установил docker-compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
- Вывод всех команд по запуску docker-compose приводить не буду, обычно, если используется compose-файл с дефолтным именем запускаю все в фоне
```bash
docker-compose up -d
```
- Получение самоподписанного сертификата для локального nginx
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
```
- Скрипт для бэкапа БД в SQL формате и очистке файлов старше суток. За основу взял уже имеющийся скрипт, и переделал его под поставленную задачу. 
- Для того, чтобы все было честно, установил MySQL сервер и создал базу для бэкапа.

3. Задание на git
- Для данного задания буду использовать свой репозиторий с скриптами и файлами для данного задания.

