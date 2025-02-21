Для выгрузки пользователей из групп AD через PowerShell

get-adgroupmember 'Doc_OFUO_4_SMA-W' | ft name | out-file C:\Users\Trofimov.Aleksey\Desktop\Admins.csv

Get-ADGroupMember - Указывает из какой группы выгружать пользователей
ft name - говорит о том чтобы были выгружены только имена пользователей
out-file - создает файл с расширением .CSV и помещает выгруженных пользователей туда, можно указать путь, в данном случае создает на рабочем столе с именем Admins 
========================================
Get-ADComputer -Filter {enabled -eq $true} -searchbase "OU=Сочи,OU=Workstations,DC=OCRV,DC=COM,DC=RZD" | FT dNSHostName, operatingSystem  | out-file D:\IB\PC\Сочи.csv

$FromOU = OU=Санкт-Петербург,OU=Workstations,DC=OCRV,DC=COM,DC=RZD
Get-ADComputer -SearchBase $FromOU -Filter {Enabled -eq $true} | FT dNSHostName | Out-File -FilePath C:\script\spb.txt
$PClist = gc "C:\script\spb.txt"
foreach ($PC in $PClist) {
wecutil ss <название подписки> /aes /esa:$PC /ese
}

Выгрузка компьютеров из AD с определенными параметрами:
-Filter {enabled -eq $true} - выбирает только включенные компьютеры в AD
-searchbase "OU=workstations,DC=OCRV,DC=COM,DC=RZD" - Где искать
-Properties Name,Operatingsystem, IPv4Address, distinguishedName, description - по каким атрибутам делать выборку
Select-Object - выбирает отобранные атрибуты, могут отличаться от properties
export-csv -Path D:\IB\PC\PC.csv -NoTypeInformation -Encoding UTF8 -Delimiter ";" - вывод в csv-файл по пути d:\ib\PC\pc.csv !Обязательно укаать делиметр, иначе все будет в одном столбце.

Get-ADComputer -Filter {enabled -eq $true} -searchbase "OU=workstations,DC=OCRV,DC=COM,DC=RZD" -Properties Name,Operatingsystem, IPv4Address, distinguishedName, description | Select-Object -Property Name,Operatingsystem, IPv4Address, distinguishedName, description | export-csv -Path D:\IB\PC\PC.csv -NoTypeInformation -Encoding UTF8 -Delimiter ";"
========================================
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
CONTAINER ID NAME CPU % MEM USAGE / LIMIT MEM % NET I/O BLOCK I/O PIDS
# docker ps -q|xargs docker stats --no-stream
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

