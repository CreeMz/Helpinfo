========================================
Очистка очереди печати 

net stop spooler
del %systemroot%\system32\spool\printers\*.shd /F /S /Q
del %systemroot%\system32\spool\printers\*.spl /F /S /Q
net start spooler

Пререзагрузка очереди печати

net restart spooler
========================================
Kyocera 8525 menu 10871087	

color belt (89>start>system>start)
chk motors (30>start)
color regist (464>start>color regist>start> regist>start)
========================================
Сброс ошибки узлов (МК А) на Куocera 8525
10871087------>251------>Clear

Разблокировка отсеков картриджей на taskalfa 2552/2553
10871087------>159------>Container Lock------>off------>start
Для блокировки выбрать "Empty" вместо off, процедура больше ничем не отличается.
========================================
Установка на гарантию для Kyocera (больших)

10871087 --> 278 --> start --> stop
========================================
