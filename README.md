# clear-atop-log
Скрипт для автоматической очистки логов atop.

### Как работает?
Скрипт clear-atop-log.sh удаляет все логи в /var/log/atop, либо только логи старше определенного количества дней.
Имеет 2 позиционных аргумента: 
1. boolean, определяет удалять ли все логи (0-удалить только логи старше определенного кличества дней, 1-удалить все логи), по умолчанию 0;
2. целое число, количество дней, за которые нужно сохранить логи. Логи старше этого количества дней удаляются, по умолчанию 90. Если первый аргумент равен 1, данный аргумент можно не указывать.
 
Для выполнения скрипта вручную нужно:
1. Перейти в папку со скриптом с помощью cd (например ```cd /home/user/Downloads```)
2. Назначить права на выполнение (```chmod a+x clear-atop-log.sh```)
3. Ввести ```./clear-atop-log.sh```. По умолчанию удаляются логи atop старше 90 дней, но можно указать нужные аргументы через пробелы после имени скрипта (например ```./clear-atop-log.sh 0 100```, чтобы удалить логи старше 100 дней; ```./clear-atop-log.sh 1```, чтобы удалить все логи)

ВНИМАНИЕ! При запуске скрипта с установочного образа linux следует использовать скрипт clear-atop-log-on-mnt.sh вместо clear-atop-log.sh. Порядок действий такой же, нужно только поменять имя скрипта.

Для успешного выполнения скрипта могут понадобиться root-права. Для этого нужно ввести ```su```, затем выполнить скрипт, либо ввести ```sudo ./clear-atop-log.sh```.

### Установка на StruxureWare Data Center Expert Server
Для установки скрипта clear-atop-log.sh на StruxureWare Data Center Expert Server и настройки его переодического выполнения используется скрипт install.sh
Рекомендуется установка в автоматическом режиме с помощью кастомного установочного образа (порядок описан в следующеё секции)

Чтобы установить скрипт вручную нужно:
1. Убедиться, что скрипты clear-atop-log.sh и install.sh находятся в одной директории
2. Перейти в папку со скриптами с помощью cd (например ```cd /home/user/Downloads```)
3. Назначить права на выполнение (```chmod a+x clear-atop-log.sh; chmod a+x install.sh```)
4. Ввести ```./install.sh```. Для успешной установки нужны root-права. Обычно при загрузке установочного образа linux производится автоматический вход под пользователем root. Если этого не произошло, нужно ввести ```su```, затем выполнить скрипт install.sh, либо ввести ```sudo ./install.sh```
5. Начнется обратный отсчет до начала установки. Установку можно отменить нажатием Ctrl+C
6. Скрипт запросит, следует ли удалить все логи atop. При вводе y или Y будут удалены все логи. При вводе любого другого значения, либо если оставить поле пустым, будут удалены логи старше определенного количества дней
   6.1. Если не удаляются все логи, то скрипт запросит ввести количество дней, за которые логи нужно оставить. Логи старше этого количества дней будут удалены
   6.2. Далее скрипт запросит ввести переодичность запуска скрипта. Используется формат crontab (5 значений, отделенные пробелом, в следующей последовательности: минуты, часы, день месяца, номер месяца, номер дня недели).
   Например: ```0 22 1 */3 *``` - запускать каждые 3 месяца в 1 число месяца в 22:00 (по умолчанию);
   ```30 19 15 * *``` - запускать 15 числа каждого месяца в 19:30;
   ```0 20 * * *``` - запускать каждый день в 20:00;
   ```0 17 * * 5``` - запускать в 17:00 по пятницам;
   ```*/5 * * * *``` - запускать каждые 5 минут.
   Больше можно прочитать [тут](https://www.nncron.ru/help/RU/working/cron-format.htm)
   6.3. Затем install.sh запросит, нужно ли запустить скрипт сейчас. При вводе y или Y скрипт будет запущен с аргументами, указанными выше
   6.4. Начнется обратный отсчет до перезагрузки сервера. Перезагрузку можно отменить нажатием Ctrl+C

Диалоги в пункте 6 имеют предел времени. При истечении времени используются параметры по умолчанию и скрипт переходит к следующему диалогу

### Автоматическая утановка с помощью кастомного установочного образа
В репозитории (где?) прикреплен .iso файл. При загрузке данного образа автоматически выполняется скрипт intall.sh. Пользователь может вводить нужные параметры с клавиатуры в ходе выполнения. Если этого не происходит, то скрипт clear-atop-log.sh устанавливается с параметрами по умолчанию. 

Записать .iso файл на flash-карту можно с помощью [rufus](https://rufus.ie/), [balena etcher](https://etcher.balena.io/) или любых подобных программ.

### Создание кастомного установочного образа на основе ArchLinux
При изменении скрипта требуется создать кастомный загрузочный образ заново. Для этого используется скрипт build-arch-iso.sh.

Для создания кастомного образа требуется:
1. Убедиться, что установлен пакет archiso: ```sudo pacman -Sy archiso```
2. Назначить права на выполнение (```chmod a+x build-arch-iso.sh```)
3. Запустить скрипт build-arch-iso.sh (потребуются root-права: ```sudo ./build-arch-iso.sh```)

Образ создается в директории /tmp/archlive. Далее .iso файл можно записать на flash-карту. Чтобы образ созранился после перезагрузки нужно, его переместить/скопировать в другую директорию (кроме /tmp и ее субдиректорий).
