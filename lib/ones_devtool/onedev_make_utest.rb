# encoding: utf-8

require 'fileutils'

module Onedev_make_utest
  UTESTS_SUFF = "utest.epf"
  UTESTS_PATH = File.join("tests","utests")
  UTESTS_SUBS_PATH = File.join(File.dirname(File.expand_path(__FILE__)),File.basename(__FILE__,".rb"),"substitutions")
  UTEST_TEMPLATE_PATH = File.join(File.dirname(File.expand_path(__FILE__)),File.basename(__FILE__,".rb"),"common.utest.epf.src")
  MDCLASS_SUBS_DEFAULT = {:hase_ui_test_sub=>"raise \"FIXME\"",
                  :test_md_def_sub=>"function ТестЗаглушкаОбъектаМД()\n raise \"FIXME В шаблоне отсутсвует реализация теста объекта МД\";\n endfunction",
                  :test_md_call_sub=>"ТестЗаглушкаОбъектаМД();",
                   }
  UTESTS = {
# ---ОбщиеКоллекции--->
    :Конфигурация => {:tmplts=>
      {
        :Конфигурация => {:tmplts=>"Конфигурация.utest.epf",:path=>"",:descr=>"Тест корневого объекта конфигураци, наличия u-тестов для объектов и коллеций МД"},
        :Подсистемы => {:tmplts=>"Подсистемы.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест структуры подсистем"},
        :ПараметрыСеанса => {:tmplts=>"ПараметрыСеанса.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции параметров сеанса"},
        :Роли => {:tmplts=>"Роли.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест структуры коллекции ролей, без тестирование прав доступа"},
        :ОбщиеРеквизиты => {:tmplts=>"ОбщиеРеквизиты.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции общих реквизитов"},
        :ПодпискиНасобытия => {:tmplts=>"ПодпискиНасобытия.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции подписки на события"},
        :РегламентныеЗадания => {:tmplts=>"РегламентныеЗадания.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции регламентные задания"},
        :ФункциональныеОпции => {:tmplts=>"ФункциональныеОпции.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции функциональные опции"},
        :ПараметрыФункциональныхОпций => {:tmplts=>"ПараметрыФункциональныхОпций.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции параметры функциональных опций"},
        :ОпределяемыеТипы => {:tmplts=>"ОпределяемыеТипы.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции определямые типы"},
        :ГруппыКомманд => {:tmplts=>"ГруппыКомманд.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции группы комманд"},
        :ОбщиеМакеты => {:tmplts=>"ОбщиеМакеты.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции ОбщиеМакеты"},
#        :ОбщиеКартинки => {:tmplts=>"ОбщиеКартинки.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции картинок"},
#        :XDTOПакеты => {:tmplts=>"XDTOПакеты.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции пакетов XDTO"},
#        :ЭлементыСтиля => {:tmplts=>"ЭлементыСтиля.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции элементов стиля"},
#        :Языки => {:tmplts=>"Языки.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции языки"},
#        :НумераторыДокументов => {:tmplts=>"НумераторыДокументов.utest.epf",:path=>"ОбщиеКоллекции",:descr=>"Тест коллекции нумераторы документов"}
      },:path=>"ОбщиеКоллекции",:descr=>"Тест корневого объекта конфигураци общих коллекций(не имеющих программных модулей) объектов МД"
    },
# <---ОбщиеКоллекции---
# ---Общие--->
    :ОбщийМодуль => {:tmplts=>"ОбщийМодуль.utest.epf",:path=>"ОбщиеМодули",:descr=>"Тест общего модуля"},
    :ПланОбмена => {:tmplts=>"ПланОбмена.utest.epf",:path=>"ПланыОбмена",:descr=>"Тест плана обмена"},
    :КритерийОтбора => {:tmplts=>"КритерийОтбора.utest.epf",:path=>"КритерииОтбора",:descr=>"Тест критерия отбора"},
    :ХранилищеНастроек => {:tmplts=>"ХранилищеНастроек.utest.epf",:path=>"ХранилищаНастроек",:descr=>"Тест Хранилища Настроек"},
    :ОбщаяФорма => {:tmplts=>"ОбщаяФорма.utest.epf",:path=>"ОбщиеФормы",:descr=>"Тест общей формы"},
    :ОбщаяКоманда => {:tmplts=>"ОбщаяКоманда.utest.epf",:path=>"ОбщиеКоманды",:descr=>"Тест Общей Команды"},
    :WebСервис => {:tmplts=>"WebСервис.utest.epf",:path=>"Web-Сервисы",:descr=>"Тест Web-сервиса"},
    :WSСсылка => {:tmplts=>"WSСсылка.utest.epf",:path=>"WS-Ссылки",:descr=>"Тест WS-Ссылки"},
# <---Общие---
    :Константа => {:tmplts=>"Константа.utest.epf",:path=>"Константы",:descr=>"Тест Константы"},
    :Справочник => {:tmplts=>"Справочник.utest.epf",:path=>"Справочники",:descr=>"Тест справочника"},
    :Документ => {:tmplts=>"Документ.utest.epf",:path=>"Документы",:descr=>"Тест Документа"},
    :Последовательность => {:tmplts=>"Последовательность.utest.epf",:path=>"Доументы",:descr=>"Тест последовательности документов"},
    :ЖурналДокументов => {:tmplts=>"ЖурналДокументов.utest.epf",:path=>"ЖурналыДокументов",:descr=>"Тест Журнала документов"},
    :Перечисление => {:tmplts=>"Перечисление.utest.epf",:path=>"Перечисления",:descr=>"Тест Перечисления"},
    :Отчет => {:tmplts=>"Отчет.utest.epf",:path=>"Отчеты",:descr=>"Тест отчета"},
    :Обработка => {:tmplts=>"Обработка.utest.epf",:path=>"Обработки",:descr=>"Тест Обработки"},
    :ПланВидовХарактеристик=> {:tmplts=>"ПланВидовХарактеристик.utest.epf",:path=>"ПланыВидовХарактеристик",:descr=>"Тест Плана Видов Характеристик"},
    :ПланСчетов => {:tmplts=>"ПланСчетов.utest.epf",:path=>"ПланыСчетов",:descr=>"Тест Плана Счетов"},
    :ПланВидовРасчета => {:tmplts=>"ПланВидовРасчета.utest.epf",:path=>"ПланыВидовРасчета",:descr=>"Тест ПланыВидовРасчета"},
    :РегистрСведений => {:tmplts=>"РегистрСведений.utest.epf",:path=>"РегистрыСведений",:descr=>"Тест Регистра Сведений"},
    :РегистрНакопления => {:tmplts=>"РегистрНакопления.utest.epf",:path=>"РегистрыНакопления",:descr=>"Тест Регистра Накопления"},
    :РегистрБухгалтерии => {:tmplts=>"РегистрБухгалтерии.utest.epf",:path=>"РегистрыБухгалтерии",:descr=>"Тест Регистра Бухгалтерии"},
    :РегистрРасчета=> {:tmplts=>"РегистрРасчета.utest.epf",:path=>"РегистрыРасчета",:descr=>"Тест Регистра Расчета"},
    :БизнесПроцесс => {:tmplts=>"БизнесПроцесс.utest.epf",:path=>"БизнесПроцессы",:descr=>"Тест Бизнес Процесса"},
    :Задача => {:tmplts=>"Задача.utest.epf",:path=>"Задачи",:descr=>"Тест Задачи"},
    :ВнешнийИсточникДанных => {:tmplts=>"ВнешнийИсточникДанных.utest.epf",:path=>"ВнешниеИсточникиДанных",:descr=>"Тест Внешнего Источника Данных"}
  }
  def self.md_name_sub(mdclass,objname)
    "#{mdclass}#{objname.to_s.length>0 ? ".#{objname}" : ""}"
  end
  
  def self.valid_mdname(mdname)
    raise "Имя объекта МД `#{mdname}' содержит запрещённые символы." if mdname =~ /(^[^a-zA-Zа-яА-Я]{1}|[^a-zA-Zа-яА-Я_0-9])/
  end
  
  def self.usage()
    UTESTS.each do |k,v|
      $stderr.puts "    #{k.to_s} - #{v[:descr]}" # if File.exist?(testsourse(k))
      if v[:tmplts].respond_to? :each
        $stderr.puts "    Состав:"
        v[:tmplts].each do |key,val|
          $stderr.puts "        #{key.to_s} - #{val[:descr]}"
        end
      end
    end
  end
  
  def self.valid_mdclass(mdclass)
    if ! UTESTS.has_key?(mdclass.to_sym) 
      $stderr.puts "Объект МД: '#{mdclass}` не поддерживается.
Доступные объекты МД:"
    Onedev_make_utest::usage
    exit 1
    end  
  end  
  
  def self.testsourse(mdclass)
    File.join(UTESTS_SUBS_PATH,"#{mdclass}.rb")
  end   
  
  def self.get_mdclass_subs(mdclass,mdname)
    testsourse = testsourse(mdclass)
    if File.exist?(testsourse)
      require File.expand_path(testsourse)
      result = Onedev_make_utest::MDCLASS_SUBS.update(:md_name_sub=>md_name_sub(mdclass,mdname))
    else
      result = Onedev_make_utest::MDCLASS_SUBS_DEFAULT.update(:md_name_sub=>md_name_sub(mdclass,mdname))
    end
    result
  end

  def self.substitute(text,subs)
    subs.each() do |k,v|
      text.gsub!(/#{k.to_s}/){|s| s=v}
    end
    text
  end

  def self.buldtest(mdclass,mdname,hash,path,args)
    class_dir = File.join(path,UTESTS_PATH,hash[:path])
    target = File.join(class_dir,"#{md_name_sub(mdclass,mdname)}.#{UTESTS_SUFF}")
    if File.exists?(target)
      $stderr.puts "ПРОПУЩЕН: Файл '#{target}` существует"
      return target
    end
    tmp_src = "/tmp/#{Time.now.strftime("%s")}.UTESTS.epf.srs.tmp"
    module_src = File.join(tmp_src,"a184be07-c0af-4e64-a266-51e9c52aa3c3.0","text")
    FileUtils.cp_r(UTEST_TEMPLATE_PATH,tmp_src)
    text = ""
    File.open(module_src,"r"){|f| text = f.read}
    text = substitute(text,get_mdclass_subs(mdclass,mdname))
    remove_const(:MDCLASS_SUBS) if const_defined?(:MDCLASS_SUBS)

    File.open(module_src,"w"){|f| f.write(text)}
    FileUtils.mkdir_p(class_dir)
    Ones_mdscontaiter.assemble(tmp_src,target)
    puts "Создан тест  '#{target}`" if args.has_key?(:verbose)
    FileUtils.rm_r(tmp_src)
    return target
  end  
  
  def self.capitalize(str)
    chars = {
      :а=>"А",
      :б=>"Б",
      :в=>"Г",
      :д=>"Д",
      :е=>"Е",
      :ж=>"Ж",
      :з=>"З",
      :и=>"И",
      :й=>"Й",
      :к=>"К",
      :л=>"Л",
      :м=>"М",
      :н=>"Н",
      :о=>"О",
      :п=>"П",
      :р=>"Р",
      :с=>"С",
      :т=>"Т",
      :у=>"У",
      :ф=>"Ф",
      :х=>"Х",
      :ц=>"Ц",
      :ш=>"Ш",
      :щ=>"Щ",
      :э=>"Э",
      :ю=>"Ю",
      :я=>"Я",
   }
   str.capitalize!
   str.gsub(/^[а-я]/){|s|
     s=chars[s.to_sym]}
  end
  

  def self.split_mdobject(mdobject)
    result={}
    arr = mdobject.split(".")
    mdclass = capitalize(arr[0])
     valid_mdname(mdclass)
    result.update(:mdclass=>mdclass)
    mdname=""
    if arr.length > 1
      mdname = capitalize(arr[1])
      valid_mdname(mdname)
    end
    result.update(:mdname=>mdname)
    result
  end

  def self.maketest(mdobject,path,args)
    args ||= {}
    mdobj_hash = split_mdobject(mdobject)
    valid_mdclass(mdobj_hash[:mdclass])
    if UTESTS[mdobj_hash[:mdclass].to_sym][:tmplts].respond_to? :each
      #Для Конфигурация создаются тесты общих коллкций объектов МД
      UTESTS[mdobj_hash[:mdclass].to_sym][:tmplts].each do |mdclass,hash|
          buldtest(mdclass,mdobj_hash[:mdname],hash,path,args)
      end
    else
          buldtest(mdobj_hash[:mdclass].to_sym,mdobj_hash[:mdname],UTESTS[mdobj_hash[:mdclass].to_sym],path,args)
    end  
  end
  
end