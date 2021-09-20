Очистка очереди печати 

net stop spooler
del %systemroot%\system32\spool\printers\*.shd /F /S /Q
del %systemroot%\system32\spool\printers\*.spl /F /S /Q
net start spooler

Пререзагрузка очереди печати

net restart spooler
========================================
Как открывать файлы с ".SIG" расширением

https://www.azfiles.ru/extension/sig.html
========================================
God Panel в Windows
1) Создать папку
2) Вставить вместо названия  GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}
========================================
Программа для смены Mac адреса сетевой карты:
Technology Mac (TMAC) 
========================================
HKU\.DEFAULT\Keyboard Layout\Preload
Поменять местами значения в ветке реестра для установки английского языка на экране приветствия.
========================================
Удаление Kaspersky в реестре и скрытых папках:

Cat_BS
Спасибо за качественный образ :)
Все заработало.....только жаль что не помогло решить проблему с каспером.....попытался удалить вручную мышь перестала фурычить - помог твой образ......
Вот по такому алгоритму действую
1) Убедиться в отсутствии следующих элементов (в случае наличия удалить их):

> Папки:
- C:\Program Data\Kaspersky Lab
- C:\Program Files\Kaspersky Lab
- C:\Program Files (x86)\Kaspersky Lab (только для 64-битных ОС)

Для отображения папки ProgramData необходимо включить опцию Отображение скрытых папок и файлов.
Для этого следуйте рекомендациям в статье: http://support.kaspersky.ru/3580

> Файлы:
- C:\Windows\system32\drivers\kl1.sys
- C:\Windows\system32\drivers\kl2.sys
- C:\Windows\system32\drivers\klelam.sys
- C:\Windows\system32\drivers\klif.sys
- C:\Windows\system32\drivers\klim5.sys
- C:\Windows\system32\drivers\klim6.sys
- C:\Windows\system32\drivers\klmouflt.sys
- C:\Windows\system32\drivers\klfltdev.sys
- C:\Windows\system32\drivers\klflt.sys
- C:\Windows\system32\drivers\klkbdflt.sys
- C:\Windows\system32\drivers\klpd.sys
- C:\Windows\system32\drivers\kltdi.sys
- C:\Windows\system32\drivers\klwfp.sys
- C:\Windows\system32\drivers\kneps.sys

> Ветки реестра:
- HKEY_LOCAL_MACHINE\SOFTWARE\KasperskyLab
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AVP
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klif
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kl1
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kl2
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klim5
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klim6
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klmouflt
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klflt
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klkbdflt
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kltdi
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kneps
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\klfltdev

Аналогично для HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001 и HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002.

Для того, чтобы зайти в редактор реестра нажмите Пуск и в строке поиска наберите команду: regedit и нажмите Enter

> Удалить значение klmouflt (только это значение, остальные оставить) из ключа UpperFilters ветки реестра HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96F-E325-11CE-BFC1-08002BE10318}
> Удалить значение klkbdflt (только это значение, остальные оставить) из ключа UpperFilters ветки реестра HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}
> Удалить значение klfltdev (только это значение, остальные оставить) из ключа UpperFilters веток реестра в разделе HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class, для которых данное значение будет обнаружено

2) Перезагрузить ПК в Безопасном режиме: http://support.kaspersky.ru/493 и запустить kavremover:
http://support.kaspersky.ru/kis2012/service?qid=208635705 на удаление KIS2013.

3) Перезагрузить ПК и в командной строке, запущенной от имени администратора, выполнить:

sc query avp

Для этого нажмите Пуск - Программы - Стандартные - нажмите правой кнопкой мыши на Командная строка и выберите Запуск от имени Администратора. Пришлите, пожалуйста, копию экрана (скриншот) результата выполнения команды.
Как сделать копию экрана вы можете прочесть здесь: http://support.kaspersky.ru/492

После этого необходимо снова выполнить установку Антивируса.
===================================================
Удаление файлов старше 3-х дней всех видов из папки при помощи PowerShell.

$path = 'E:\SCAN'
Get-ChildItem -Path $path -Recurse -File | ? {$_.CreationTime  -le ( (Get-Date).adddays(-3) ) } | Remove-Item -Force -Recurse
===================================================
Отключение удаления ярлыков. windows 7
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\ScheduledDiagnostics]
"IsUnusedDesktopIconsTSEnabled"=dword:00000000
"IsBrokenShortcutsTSEnabled"=dword:00000000
===================================================
Открытие Excel файлов в 2х не связанных окнах

1. Отредактировать реестр, ветка HKEY_CLASSES_ROOT\Excel.Sheet.8\shell\Open\command
1.1. Элемент «По умолчанию» заменить значение «/dde» на «/e “%1”»
1.2. Произвольно переименовать элемент «command»
1.3. Произвольно переименовать раздела «ddeexec»
2. Повторить шаги 1.1.-1.3. для ветки HKEY_CLASSES_ROOT\Excel.Sheet.12\shell\Open\command
================================================
Перезагрузка компьютера с принудительным завершением программ (cmd)

shutdown /t 0 /r /f /m \\имя компа

/t 0 - выполнение команды через 0 секунд
/r - уточнение о том, что команда должна перезагрузить
/f - закрывает принудительно работающие процессы
/m - имя машины которую нужно перезагрузить
=================================================
nslookup -type=any
вывод всей доступной информации о пк в cmd по имени.
================================================
Добавление маршрута:

route add -p "сеть" mask "mask" "шлюз"
-p	-	добавляет маршрут в реестр
=================================================
Для принудительного запуска поиска обновлений: wuauclt /detectnow

Бывает что проверка обновлений говорит что таковых нет, но это не так. Для сброса авторизации и соответственно списка полученных обновлений: wuauclt /resetAuthorization

Сбросить на сервер список уже установленных обновлений: wuauclt /reportnow

Запускает процесс установки найденных обновлений: wuauclt /UpdateNow
========================================
