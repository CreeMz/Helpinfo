Для принудительного запуска поиска обновлений: wuauclt /detectnow

Бывает что проверка обновлений говорит что таковых нет, но это не так. Для сброса авторизации и соответственно списка полученных обновлений: wuauclt /resetAuthorization

Сбросить на сервер список уже установленных обновлений: wuauclt /reportnow

Запускает процесс установки найденных обновлений: wuauclt /UpdateNow
========================================
Перенос групп одного пользователя, другому.

' Получение "базового" набора объекта от пользователя,
' которого мы хотим скопировать членство
Set objTemplate = GetObject("LDAP://cn=userName1,ou=ouName,dc=MyDomain,dc=com")

' Пользователь, которому хотим скопировать
Set objUser = GetObject("LDAP://cn=userName2,ou=ouName,dc=MyDomain,dc=com")

' Перебираем группы первого юзера
For Each objGroup In objTemplate.Groups
    ' Проверка членства в группах второго юзера
    If (objGroup.IsMember(objUser.AdsPath) = False) Then
        ' Если нет, то добавляем в группу
        objGroup.Add(objUser.AdsPath)
    End If
Next
===================================================
Удаление файлов старше 3-х дней всех видов из папки при помощи PowerShell.

$path = 'E:\SCAN'
Get-ChildItem -Path $path -Recurse -File | ? {$_.CreationTime  -le ( (Get-Date).adddays(-3) ) } | Remove-Item -Force -Recurse
===================================================
Установка OS Synology DSM 6.1_DS3615
Необходимые компоненты:
1. Скачать Rufus * нужен для записи образа загрузчика
2. Скачать OSFMount * программа для монтирования *.img файлов, нужна для правки файла "grub.cfg"
3. Скачать Synology Assistant - программа для поиска NAS
4. Скачать загрузчик. В данном случае используется DS3615xs 6.1 Jun's Mod V1.02b.img
5. Скачать дистрибутив системы подходящий к нашему загрузчику в нашем случае DSM_DS3615xs_15254
6. Флешка 128+ МБ
7. Скачать программу ChipEasy_EN_V1.5.6.6. Нужен чтобы узнать VID и PID флешки.
Процесс установки:
1. Устанавливаем OSFMount, с его помощью примонтируем образ нашего загрузчика: "DS3615xs 6.1 Jun's Mod V1.02b.img".
2. Внутри ищем файл "grub.cfg"
3. Подменяем значения VID и PID, на те которые присвоины нашей флешке.
4. С помощью Rufus записываем образ на нашу флешку.
5. Загружаем копьютер для NAS с Флешки.
6. Выбираем первый пункт.
7. На свою машину ставим Synology Assistant и запускаем, или переходим на http://find.synology.com
8. При выборе установки выбираем чистую и ручную.
9. Выбираем образ: DSM_DS3615xs_15254
10. Ждем окончания установки.
11. Готово, вы великолепны.

!!!
СИСТЕМУ НЕЛЬЗЯ ОБНОВЛЯТЬ АВТОМАТИЧЕСКИ.
ФЛЕШКА ВСЕГДА ВОТКНУТА В КОМП ПРИ ЗАПУСКЕ.
===================================================
Нахождение пароля LAPS в Active Directory
Нужно найти атрибут ms-Mcs-AdmPwd
===============================================
Создание фул чейн сертификата:

В текстовом файле соеденить сертификаты в последовательности:

1.certificate.crt
2.ca_bundle.crt
3.root.cer
==============================================
Когда отваливаются клиентские лицензии 1С
1. Перезапустить HASP Loader
================================================
Ссылка на КЗД в 1с
ctrl+f11
================================================
Носитель MySQL server Можно посмотреть при установки, называется медиа обычно в корне.
Ставить оттуда.
================================================
Создание keytab-файла
Keytab-файлы используются в удаленных системах, поддерживающих Kerberos, для аутентификации пользователей без ввода пароля., содержащий имена субъекта-службы (далее также "Spn"). 

setspn -A HTTP/"workstation.domain@domain" "domain\username"
ktpass /mapuser "domain\username"  /princ HTTP/workstation.domain  /ptype KRB5_NT_PRINCIPAL /pass "password"  /crypto ALL  /out filename.keytab +answer

workstation.domain - имя рабочей станции
domain\username - имя пользователя
password - пароль пользователя
Так же может присутствовать параметр target (один из dc)
==============================================
Закрытие открытого файла на linux (SMB)

#Отображает информацию о файле который надо закрыть (нужен pid)
sudo smbstatus -L | grep -i "Часть_имени_файла"

#Показывает у какого пользователя открыт файл (pid без кавычек)
sudo smbstatus -u | grep "pid"

#Закрывает сессию smb по "pid" (писать без кавычек)
kill -9 "pid"
=========================================================
Закрытие сессии на терминальном сервере через pscx PowerShell

# Установка Модуля
Install-Module Pscx -Scope CurrentUser

# Обновление Модуля
Update-Module Pscx

# Просмотр всех сейссий на удаленном столе:
Get-TerminalSession -ComputerName *Имя сервера*

# Принудительное завершение сессии
Stop-TerminalSession -ComputerName *Имя сервера* -Id *id пользователя* -force
========================================================
r-virt
добавть ноду хранилище
/usr/libexec/vstorage-ui-agent/bin/register-storage-node.sh -m 172.22.10.96 -t ключ_посмотреть_на_морде_схд

добавить ноду в ha
hastart -c cl01 -n 192.168.90.0/24


cat /etc/vz/vz.conf - конфиг ноды

prlctl restart vstorage-ui - рестарт хранилища
vstorage -c cl01 stat      - мониторинг хранилища
prlsrvctl problem-report -d > report.tgz      - логи
prlctl list - машины на ноде
prlctl migrate имя_вм ip_ноды - миграция

prlctl start\stop\status имя вм  - запустить\остановит\посмотреть статус вм
prlctl unregister имя_вм - удалить задублированную вм
vz-guest-tools-updater имя вм   -монтирование диска со средствами управления
shaman stat\top - статус нод и расположения вм

https://docs.virtuozzo.com/virtuozzo_hybrid_server_7_users_guide/  - вики аналогичного продукта



разобрать HA (запускать на конкретной ноде)
Disable and stop HA services:

# systemctl disable shaman.service
# systemctl stop shaman.service
# systemctl disable pdrs.service
# systemctl stop pdrs.service
Remove the node from the HA configuration. For example, for a node in the cluster vstor1, run:

# shaman -c vstor1 leave
=========================================================
Конвертация диска с hyper-v на basealt с подключением к машине:

1. Скопировать диск на ноду, зайти на неё по ssh, провалиться в нужную папку
2. Выполнить команду:
qm importdisk <id вм> <имя диска> <хранилище>
qm importdisk 126 POSTGRES.vhdx HDD
3. Дождаться окончания процесса конвертации.
========================================================
Установка python и Ansible на Astra Linux 1.7

apt install pwgen wget python3 python3-pip sshpass jq
python3 -m pip install jmespath netaddr jinja2
========================================================
Управление ipa\ald

ipactl status - состояние домена
sudo ipactl restart - перезапуск служб ipa
========================================================
Посмотреть базы и сколько в них свободного места на сервере

Get-MailboxDatabase -Server mail.ocrv.com.rzd -Status | select Name, DatabaseSize, AvailableNewMailboxSpace
========================================================
# docker ps -q|xargs docker stats --no-stream	-	Выводит данные о контейнерах в формате CONTAINER ID NAME CPU % MEM USAGE / LIMIT MEM % NET I/O BLOCK I/O PIDS
# docker ps -a --filter volume=VOLUME_NAME_OR_MOUNT_POINT - узнать куда прикрепляется docker volume
# docker system df -v - узнать размер и имена всех docker volume
# docker ps --size - размер всех контейнеров
# docker volume ls - выводит список томов
# docker logs  --since "2026-02-18T9:00:00" --until "2026-02-19T9:00:00" "cont-name" > out-file.txt
========================================================
На клиенте:
sudo salt-call -c /srv/salt/standalone/config/ gp_sum.build_and_run_gp force=True
========================================================
На КД:
sudo salt-call state.apply gpupdate.swp -c /srv/salt/standalone/config/ pillar='{"verbose": True, "force":True}'
========================================================
Время следующего запуска:
sudo salt-call schedule.show_next_fire_time build_and_run_gp -c /srv/salt/standalone/config
========================================================
Конфиг расписания запуска:
/srv/salt/standalone/config/minion.d/standalone_scheduler.conf
========================================================
Проверка домена:
astra-freeipa-client -i
========================================================
Исправление квадратов на альт-линухе в графике.

chkconfig consolesaver on
chkconfig keytable on
fc-cache -f -v
MicroSoft TTF Fonts поставить
========================================================
Форсирование политик
На клиенте:
вариант1 - sudo aldpro-gpupdate --gp
вариант2 - sudo salt-call -c /srv/aldpro-salt/config gp_sum.build_and_run_gp force=True
---------------------
На КД:
sudo salt-call state.apply gpupdate.swp -c /srv/salt/standalone/config/ pillar='{"verbose": True, "force":True}'
---------------------
Время следующего запуска:
sudo aldpro-salt-call schedule.show_next_fire_time build_and_run_gp -c /srv/salt/standalone/config
---------------------
Конфиг расписания запуска:
/srv/aldpro-salt/config/minion.d/standalone_scheduler.conf
========================================================
Проверка домена:
astra-freeipa-client -i
========================================================
Вывод списка вм на hyperv с путями их дисков
$hosts = "server-01","server-02"
Get-VMHardDiskDrive -ComputerName $hosts -VMName * | select VMname, path
========================================================
Миграция AD в AldPro

На сервере aldpro
nano /etc/bind/ipa-options-ext.conf
dnssec-validation no;mp
========================================================
Шпаргалка по proxmox:

ceph osd lspools - выводит список пулов

копирование диска
rbd -p NVME (pool) export vm-115-disk-3 (имя диска, можно посмотреть в /etc/pve/nodes) /mnt/pve/MSK_NAS01/images/vm-115-disk-3.raw (куда сохранять)

Задание аргументов для вм
qm set <VM_ID> --args '-<ARG_TYPE>,<+arg1;-arg2...:argN>' <parametr1 parametr2 .... parametrN>
Пример
qm set 101 --args '-cpu host,+vmx'
Тип цпу в аргументе дожен совпадать с выбранным типом на вм

Parametrs
--acpi <boolean>              # Включить ACPI
--agent <list>                # Включить агент QEMU
--args <string>               # Произвольные аргументы QEMU (то, что вам нужно)
--balloon <integer>           # Максимальный размер баллонной памяти
--bios <ovmf|seabios>         # Тип BIOS
--boot <string>               # Порядок загрузки
--cdrom <volume>              # Привод CD-ROM
--cicustom <string>           # Пользовательские файлы для CI
--cipassword <string>         # Пароль для Cloud-Init
--citype <string>             # Тип Cloud-Init конфигурации
--cores <integer>             # Количество ядер CPU
--cpu <string>                # Тип процессора
--cpulimit <number>           # Лимит CPU
--cpuunits <integer>          # Вес CPU
--delete <string>             # Удалить параметр
--description <string>        # Описание ВМ
--digest <string>             # Хеш конфигурации
--efidisk0 <volume>           # EFI диск
--force <boolean>             # Принудительное применение
--freeze <boolean>            # Заморозить ВМ при старте
--hookscript <volume>         # Скрипт-хук
--hotplug <string>            # Горячее подключение устройств
--hugepages <integer>         # Использование hugepages
--ide<0-3> <volume>           # IDE устройства
--ipconfig<n> <string>        # Настройки IP для Cloud-Init
--keyboard <string>           # Раскладка клавиатуры
--kvm <boolean>               # Включить KVM ускорение
--localtime <boolean>         # Использовать локальное время
--lock <string>               # Заблокировать ВМ
--machine <string>            # Тип машины
--memory <integer>            # Объем памяти в МБ
--migrate_downtime <number>   # Время простоя при миграции
--migrate_speed <integer>     # Скорость миграции
--name <string>               # Имя ВМ
--net<n> <string>             # Сетевые интерфейсы
--noout <boolean>             # Без вывода
--numa <boolean>              # Включить NUMA
--numkeys <integer>           # Количество ключей
--onboot <boolean>            # Запуск при старте хоста
--ostype <string>             # Тип гостевой ОС
--parallel<0-3> <device>      # Параллельные порты
--protection <boolean>        # Защита от удаления
--reboot <boolean>            # Перезагрузка после применения
--revert <string>             # Откатить изменения
--sata<0-5> <volume>          # SATA устройства
--scsi<0-30> <volume>         # SCSI устройства
--scsihw <string>             # Тип SCSI контроллера
--serial<0-3> <device>        # Последовательные порты
--shares <integer>            # Общие ресурсы
--skiplock <boolean>          # Игнорировать блокировку
--smbios <string>             # SMBIOS настройки
--smp <integer>               # Количество виртуальных CPU
--snapname <string>           # Имя снапшота
--sockets <integer>           # Количество сокетов CPU
--spice_enhancements <string> # Улучшения SPICE
--startdate <string>          # Дата старта
--startup <string>            # Порядок запуска
--storage <string>            # Хранилище по умолчанию
--tablet <boolean>            # Устройство ввода tablet
--tags <string>               # Теги
--tdf <boolean>                # task distribution function
--template <boolean>          # Сделать шаблоном
--timeout <integer>           # Таймаут операций
--tpmstate0 <volume>          # Состояние TPM
--unused<0-...> <volume>      # Неиспользуемые тома
--usb<n> <string>             # USB устройства
--vga <string>                # Видеоадаптер
--virtio<0-...> <volume>      # VirtIO блок-устройства
--vmgenid <string>            # VM Generation ID
--vmstatestorage <string>     # Хранилище для состояния ВМ
--watchdog <device>           # Watchdog устройство

Просмотр списка устройств с аргументами
qemu-system-x86_64 - (далее TAB)
Просмотр всех значений аргументов устройств
qemu-system-x86_64 -cpu help 
========================================================
Полное восстановление grub EFI в astra Linux:

1. Загружаемся с liveCD
2. Запускаем терминал:
3. lsblk -l # Узнаем на каких дисках у нас корневая система и boot
4. Монтирование корневой системы
mount /dev/sda2 /mnt          # Монтирует корневой раздел (/) в /mnt
5. Монтирование загрузочного раздела
	-	mount /dev/sda1 /mnt/boot      # Монтирует раздел /boot или ESP
6. Бинд-монтирование системных каталогов
	-	mount --bind /dev /mnt/dev     # Связывает каталог устройств
	-	mount --bind /proc /mnt/proc   # Связывает информацию о процессах
	-	mount --bind /sys /mnt/sys     # Связывает системные данные ядра
7. Монтирование UEFI переменных (для UEFI систем)
	-	mount -t efivarfs efivarfs /sys/firmware/efi/efivars
8. Переход в chroot-окружение
	-	chroot /mnt
9. Поиск и Установка/переустановка ядра (для Debian/Ubuntu)
	-	apt search linux-image	#Поиск ядра
	-	apt install --reinstall linux-image-<версия ядра> #Переустановка ядра
10. Редактирование конфигурации GRUB	# Позволяет видеть другие установленные ОС (может понадобится если в загрузчике не видно ядра)
	-	nano /etc/default/grub         # Изменить GRUB_DISABLE_OS_PROBER=false
11. Переустановка GRUB для UEFI
	-	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
12. Обновление конфигурации GRUB
	-	grub-mkconfig -o /boot/grub/grub.cfg
13. Выход из chroot и перезагрузка
	-	exit
	-	reboot

Как использовать?
	1.	При ошибке "Welcome to GRUB" (нет меню загрузки) > выполните шаги 1–13.
	2.	Если GRUB не видит ядро > шаг 9.
	3.	Для восстановления UEFI-загрузки > шаги 1-7, 11–12.
Примечания:
	1.	Если /boot находится в корневом разделе, пропустите команду монтирования /boot
	2.	Для систем с BIOS (Legacy) вместо UEFI-установки используйте:
		-	grub-install /dev/sda
Важные замечания:
	1.	Все команды выполняются из LiveCD/LiveUSB среды
	2.	Перед выполнением проверьте правильность указания разделов с помощью lsblk или fdisk -l
	3.	Для успешной работы os-prober другие ОС должны быть на смонтированных разделах
========================================================