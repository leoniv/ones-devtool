# Ones_devtool

Набор консольных утилит для работы с платформой [1С:Предприятие v8.3](http://v8.1c.ru/)

**Данный проект закрыт !!!** 

> Он начинался на коленке и был первым опытом программирования на Ruby. По мере приобретения опыта стало понятно, что код этого проекта не выдерживает ни какой критики и его надо закрывать. 

**Добро пожаловать в :**

- [ass_launcher](https://github.com/leoniv/ass_launcher)
- [ass_ole](https://github.com/leoniv/ass_ole)
- [ass_maintainer-info_base](https://github.com/leoniv/ass_maintainer-info_base)
- [ass_tests](https://github.com/leoniv/ass_tests)
- [ass_devel](https://github.com/leoniv/ass_devel)

Целью которых является создание удобных инструментов работы с платформой 1С как для разработчиков на языке 1С так и для администраторов информационных баз.

## Требования к окружению

Это будет работать только в [cygwin](https://www.cygwin.com/).

Требуются cygwin пакеты `ruby`, `ruby-gem`, `git`, `ssh`

В ruby требуется gem `bundler`

Тестировалось в ruby 1.9.3
Работает в ruby 2.2.2


## Установка

* Клонируем
```
$ git clone https://github.com/leoniv/ones-devtool.git && cd ones-devtool
```
* Переключаемся на последний релиз 0.6.x
```
$ git checkout r.0.6.x
```
* Устанавливаем зависимости
```
 $ bundler install
```
* Собираем и устанавливаем gem
```
$ gem build ones_devtool.gemspec
$ gem install ones_devtool-0.6.0-x86-cygwin.gem
```

## Стронее ПО

- [v8unpuck](https://github.com/leoniv/v8unpack)
- zlib1.dll

## Консольные утилиты

Все утилиты имеют префикс `onedev-` и выводят справку при запуске с ключем `-h`. Утилиты по группам описаны ниже.

Путь поиска установленных дистрибутивов платформы: `$PROGRAMFILES/1cv8` можно переопределить установив переменную `$ASSPATH`.

По умолчанию используется последняя версия платформы. Это можно изменить установив переменную `$ASSPLATFORM`.

### Запуск платформы

```
$ onedev-start-disigner
$ onedev-start-enterprise
$ onedev-start-testclient
$ onedev-start-testmng
```

### Разборка и сборка контейнеров 1С

Сборщики `onedev-assemble` могут собирать 1С контейнеры из заданной ревизии `git` если хранить разобранные контейнеры под контролем `git`

```
$ onedev-assemble-cf
$ onedev-assemble-cf-fromf
$ onedev-dissass-cf
$ onedev-dissass-cf-tof
```

### Дамп и загрузка конфигурации информационной базы

```
$ onedev-dump-dbcf-tocf
$ onedev-dump-dbcf-tof
$ onedev-dump-ibcf-tocf
$ onedev-dump-ibcf-tof
$ onedev-load-dbcf-fromcf
$ onedev-load-dbcf-fromf
$ onedev-load-ibcf-fromcf
$ onedev-load-ibcf-fromf
```

### Дамп информационной базы

```
$ onedev-dump-infobase
```

### Создание информационной базы

**Ограничение:** только файловые информационные базы.

```
$ onedev-mkib
$ onedev-mkib-fromcf
$ onedev-mkib-fromdt
$ onedev-mkib-fromf
```

### Прочее

`$ onedev-prettymds` - причесывает поток mds вставляя переносы строк результат выдает на stdout.

## Известные проблемы

* `onedev-dissass-cf` использует [эту версию v8unpuck](https://github.com/leoniv/v8unpack) который может падать в `segmentation fault` при разборке патченного файла конфигурации поставщика после обновления которое удаляет объекты метаданных. Наблюдается в конфигурации 1С БП 3.0. Лечится заливкой чистой конфигурации поставщика в патченную информационную базу и слиянием с конфигурацией базы данных. Возможно версия [v8unpack](https://github.com/dmpas/v8unpack/network) от [dmpas](https://github.com/dmpas) лишена этого недостатка.
* Ограничения на длину имен файлов. При разборе конфигурации в xml файлы платформа 1С генерит плоскую структуру метаданных и получаются слишком длинные имена файлов которые могут выходить за ограничения. Эта проблема проявляется в cygwin окружении и причина её описана [сдесь](https://cygwin.com/ml/cygwin/2013-12/msg00183.html).

# Лицензия

MIT

