# Автоматическое обновление существующей подписки Windows Event Forwarding
# Получает компьютеры из трех разных OU и обновляет подписку

# Настройки
$DomainController = ""  # Имя контроллера домена
$SubscriptionName = ""  # Имя существующей подписки

# Три разные OU (не дочерние)
$OU1 = "destignition name1"
$OU2 = "destignition name2"  
$OU3 = "destignition name3"

# Упрощенный скрипт
$computers = wecutil gs $SubscriptionName

 Write-Host "=== Получение и удаление компьютеров из подписки: $SubscriptionName ===" -ForegroundColor Cyan

    # 1. Получаем конфигурацию
    Write-Host "`n1. Получаю конфигурацию подписки..." -ForegroundColor White
    $config = wecutil gs $SubscriptionName 2>$null
    
    if (-not $config) {
        Write-Host "   ✗ Подписка не найдена или пустая" -ForegroundColor Red
        return
    }
    
    Write-Host "   ✓ Конфигурация получена" -ForegroundColor Green

    # 2. Ищем компьютеры
    Write-Host "`n2. Ищу компьютеры в конфигурации..." -ForegroundColor White
    $computers = @()
    $lines = $config -split "`n"

    foreach ($line in $lines) {
        if ($line -match 'EventSourceAddress\s*[:=]\s*(.+)') {
            $value = $matches[1].Trim()
            # Если несколько компьютеров через разделитель
            if ($value -match '[,;]') {
                $computers += $value -split '[,;]' | ForEach-Object { $_.Trim() }
            } else {
                $computers += $value
            }
        }
        elseif ($line -match 'Address\s*[:=]\s*(.+)') {
            $value = $matches[1].Trim()
            if ($value -match '[,;]') {
                $computers += $value -split '[,;]' | ForEach-Object { $_.Trim() }
            } else {
                $computers += $value
            }
        }
    }

    # Убираем дубликаты и пустые значения
    $computers = $computers | Where-Object {$_} | Select-Object -Unique

    if ($computers.Count -eq 0) {
        Write-Host "   ✓ Компьютеры не найдены" -ForegroundColor Green
        return
    }

    Write-Host "   ✓ Найдено компьютеров: $($computers.Count)" -ForegroundColor Green
    Write-Host "`nСписок компьютеров:" -ForegroundColor Cyan
    $computers | ForEach-Object { Write-Host "   - $_" -ForegroundColor White }

    # 3. Удаляем каждый компьютер
    Write-Host "`n3. Удаляю компьютеры..." -ForegroundColor White
    $successCount = 0
    $errorCount = 0

    foreach ($pc in $computers) {
        Write-Host "   Удаляю $pc..." -NoNewline
        $result = wecutil ss $SubscriptionName /esa:"$pc" /res 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " ✗" -ForegroundColor Red
            $errorCount++
        }
        
        # Небольшая пауза между удалениями
        Start-Sleep -Milliseconds 100
    }

Write-Host "Готово!" -ForegroundColor Green

Write-Host "`nКонфигурация:" -ForegroundColor Yellow
Write-Host "Подписка: $SubscriptionName" -ForegroundColor Gray
Write-Host "Контроллер домена: $DomainController" -ForegroundColor Gray
Write-Host ""


# Получаем компьютеры из всех трех OU
Write-Host "Получение компьютеров из Active Directory..." -ForegroundColor Yellow

$allComputers = @()

try {
    # Первая OU
    Write-Host "Обработка OU1..." -ForegroundColor DarkGray
    $computers1 = Get-ADComputer -Filter * -SearchBase $OU1 -SearchScope Subtree -Server $DomainController |
                  Where-Object {$_.Enabled -eq $true} |
                  Select-Object -ExpandProperty DNSHostName
    $allComputers += $computers1
    Write-Host "  Найдено: $($computers1.Count)" -ForegroundColor Green
    
    # Вторая OU
    Write-Host "Обработка OU2..." -ForegroundColor DarkGray
    $computers2 = Get-ADComputer -Filter * -SearchBase $OU2 -SearchScope Subtree -Server $DomainController |
                  Where-Object {$_.Enabled -eq $true} |
                  Select-Object -ExpandProperty DNSHostName
    $allComputers += $computers2
    Write-Host "  Найдено: $($computers2.Count)" -ForegroundColor Green
    
    # Третья OU
    Write-Host "Обработка OU3..." -ForegroundColor DarkGray
    $computers3 = Get-ADComputer -Filter * -SearchBase $OU3 -SearchScope Subtree -Server $DomainController |
                  Where-Object {$_.Enabled -eq $true} |
                  Select-Object -ExpandProperty DNSHostName
    $allComputers += $computers3
    Write-Host "  Найдено: $($computers3.Count)" -ForegroundColor Green
    
    # Убираем дубликаты и сортируем
    $allComputers = $allComputers | Sort-Object -Unique
    
    Write-Host "`nИтого уникальных компьютеров: $($allComputers.Count)" -ForegroundColor Cyan
    
    if ($allComputers.Count -eq 0) {
        Write-Host "ОШИБКА: Не найдено компьютеров!" -ForegroundColor Red
        exit 1
    }
    
    # Сохраняем список компьютеров в файл
    $computersFile = "C:\Temp\${SubscriptionName}_computers_$(Get-Date -Format 'yyyyMMdd').txt"
    $allComputers | Out-File -FilePath $computersFile -Encoding UTF8
    Write-Host "Список компьютеров сохранен в: $computersFile" -ForegroundColor Green
}
catch {
    Write-Host "ОШИБКА при получении компьютеров: $_" -ForegroundColor Red
    exit 1
}

# Проверяем существование подписки
Write-Host "`nПроверка существующей подписки..." -ForegroundColor Yellow

try {
    $existingSubscriptions = wecutil es 2>$null
    
    if ($existingSubscriptions -contains $SubscriptionName) {
        Write-Host "Подписка '$SubscriptionName' найдена" -ForegroundColor Green
        
        # Даем время на обработку
        Start-Sleep -Seconds 2
    }
    else {
        Write-Host "Подписка '$SubscriptionName' не найдена, создаем новую..." -ForegroundColor Yellow
        
        # Создаем базовую подписку
        $tempXml = "$env:TEMP\${SubscriptionName}_temp.xml"
        $basicXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<Subscription xmlns="http://schemas.microsoft.com/2006/03/windows/events/subscription">
    <SubscriptionId>$SubscriptionName</SubscriptionId>
    <SubscriptionType>CollectorInitiated</SubscriptionType>
    <Description>Created $(Get-Date -Format 'yyyy-MM-dd')</Description>
    <Enabled>true</Enabled>
    <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
    <ConfigurationMode>Custom</ConfigurationMode>
    <Delivery Mode="Pull">
        <Batching>
            <MaxItems>1000</MaxItems>
            <MaxLatencyTime>1000</MaxLatencyTime>
        </Batching>
    </Delivery>
    <ContentFormat>RenderedText</ContentFormat>
    <LogFile>ForwardedEvents</LogFile>
</Subscription>
"@
        
        $basicXml | Out-File $tempXml -Encoding UTF8
        wecutil cs $tempXml 2>&1 | Out-Null
        Remove-Item $tempXml -Force -ErrorAction SilentlyContinue
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Базовая подписка создана" -ForegroundColor Green
        }
        else {
            Write-Host "Не удалось создать базовую подписку" -ForegroundColor Red
            exit 1
        }
    }
}
catch {
    Write-Host "ОШИБКА при работе с подпиской: $_" -ForegroundColor Red
    exit 1
}

# Добавляем новые компьютеры в подписку
Write-Host "`nДобавление новых компьютеров в подписку..." -ForegroundColor Yellow

$addedCount = 0
$errorCount = 0
$totalComputers = $allComputers.Count

# Обрабатываем компьютеры группами по 10 для отображения прогресса
$groupSize = 10
$groups = [math]::Ceiling($totalComputers / $groupSize)

for ($i = 0; $i -lt $groups; $i++) {
    $startIndex = $i * $groupSize
    $endIndex = [math]::Min($startIndex + $groupSize - 1, $totalComputers - 1)
    
    Write-Host "`nГруппа $($i+1)/$groups (компьютеры $($startIndex+1)-$($endIndex+1))..." -ForegroundColor DarkGray
    
    for ($j = $startIndex; $j -le $endIndex; $j++) {
        $computer = $allComputers[$j]
        $computerName = $computer.Split('.')[0]  # Берем только имя без домена
        
        try {
            Write-Host "  Добавление: $computerName" -NoNewline -ForegroundColor DarkGray
            
            # Добавляем компьютер в подписку
            $result = wecutil ss $SubscriptionName /aes /esa:$computerName /ese 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " ✓" -ForegroundColor Green
                $addedCount++
            }
            else {
                Write-Host " ✗ (ошибка)" -ForegroundColor Red
                $errorCount++
                
                # Пробуем альтернативный вариант
                Write-Host "    Попытка альтернативного метода..." -ForegroundColor DarkGray
                $result2 = wecutil ss $SubscriptionName /a:$computerName 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "    ✓ Добавлено через альтернативный метод" -ForegroundColor Green
                    $addedCount++
                    $errorCount--
                }
            }
        }
        catch {
            Write-Host "  ✗ Исключение: $computerName" -ForegroundColor Red
            $errorCount++
        }
    }
    
    # Обновляем прогресс
    $progress = [math]::Round(($j + 1) / $totalComputers * 100)
    Write-Host "Прогресс: $progress% ($($j+1)/$totalComputers)" -ForegroundColor Cyan
}

# Выводим итоги
Write-Host "`n=== РЕЗУЛЬТАТ ДОБАВЛЕНИЯ ===" -ForegroundColor Cyan
Write-Host "Всего компьютеров для добавления: $totalComputers" -ForegroundColor Gray
Write-Host "Успешно добавлено: $addedCount" -ForegroundColor Green
Write-Host "Ошибок при добавлении: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })

# Проверяем итоговое количество компьютеров в подписке
Write-Host "`nПроверка итогового состояния подписки..." -ForegroundColor Yellow

try {
    $finalConfig = wecutil gs $SubscriptionName /format:xml 2>&1
    
    if ($finalConfig -match "<Source>") {
        $finalComputers = [regex]::Matches($finalConfig, '<Source>([^<]+)</Source>') | ForEach-Object { $_.Groups[1].Value }
        Write-Host "Компьютеров в подписке после обновления: $($finalComputers.Count)" -ForegroundColor Green
        
        if ($finalComputers.Count -gt 0) {
            Write-Host "Пример компьютеров в подписке:" -ForegroundColor DarkGray
            $finalComputers | Select-Object -First 5 | ForEach-Object { 
                Write-Host "  - $_" -ForegroundColor DarkGray 
            }
            if ($finalComputers.Count -gt 5) {
                Write-Host "  ... и еще $($finalComputers.Count - 5)" -ForegroundColor DarkGray
            }
        }
    }
    else {
        Write-Host "Не удалось получить список компьютеров из подписки" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Ошибка при проверке подписки: $_" -ForegroundColor Yellow
}

# Дополнительная проверка состояния
Write-Host "`nПроверка состояния подписки..." -ForegroundColor Yellow
try {
    $status = wecutil gr $SubscriptionName 2>&1
    if ($status -match "Enabled.*true") {
        Write-Host "Статус: Подписка активна" -ForegroundColor Green
    }
}
catch {
    Write-Host "Не удалось проверить статус подписки" -ForegroundColor Yellow
}

Write-Host "`n=== ВЫПОЛНЕНИЕ ЗАВЕРШЕНО ===" -ForegroundColor Green
Write-Host "Общее время выполнения: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Создаем отчет
$reportFile = "C:\Temp\${SubscriptionName}_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$reportContent = @"
=== ОТЧЕТ ОБ ОБНОВЛЕНИИ ПОДПИСКИ ===
Время выполнения: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Имя подписки: $SubscriptionName

ИСТОЧНИКИ ДАННЫХ:
- OU1: $OU1
- OU2: $OU2  
- OU3: $OU3

СТАТИСТИКА:
- Всего компьютеров найдено: $totalComputers
- Успешно добавлено в подписку: $addedCount
- Ошибок при добавлении: $errorCount

Список компьютеров сохранен в: $computersFile
"@

$reportContent | Out-File $reportFile -Encoding UTF8
Write-Host "Отчет сохранен в: $reportFile" -ForegroundColor Green

Write-Host "`nКоманды для проверки:" -ForegroundColor Cyan
Write-Host "  wecutil gs $SubscriptionName /format:xml | Select-String '<Source>' | Measure-Object" -ForegroundColor DarkGray
Write-Host "  Get-WinEvent -LogName ForwardedEvents -MaxEvents 10" -ForegroundColor DarkGray

exit 0