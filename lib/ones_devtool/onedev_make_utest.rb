# encoding: utf-8

require 'fileutils'

module Onedev_make_utest
  UTESTS_SUFF = "utest.epf"
  UTESTS_PATH = File.join("tests","utests")
  UTESTS_TMPLTS_PATH = File.join(File.dirname(__FILE__),File.basename(__FILE__,".rb"),"templates")
  UTESTS = {
    :ОбщийМодуль => {:tmplts=>"ОбщийМодуль.utest.epf",:path=>"ОбщиеМодули",:descr=>"Тест общего модуля"},
#    :ПланОбмена => {:tmplts=>"ПланОбмена.utest.epf",:path=>"ПланыОбмена",:descr=>"Тест плана обмена"},
#    :ХранилищеНастроек => {:tmplts=>"ХранилищеНастроек.utest.epf",:path=>"ХранилищаНастроек",:descr=>"Тест Хранилища Настроек"},
    :ОбщаяФорма => {:tmplts=>"ОбщаяФорма.utest.epf",:path=>"ОбщиеФормы",:descr=>"Тест общей формы"},
    :ОбщаяКоманда => {:tmplts=>"ОбщаяКоманда.utest.epf",:path=>"ОбщиеКоманды",:descr=>"Тест Общей Команды"},
    :WebСервис => {:tmplts=>"WebСервис.utest.epf",:path=>"Web-Сервисы",:descr=>"Тест Web-сервиса"},
#    :WSСсылка => {:tmplts=>"WSСсылка.utest.epf",:path=>"WS-Ссылки",:descr=>"Тест WS-Ссылки"},
    :Константа => {:tmplts=>"Константа.utest.epf",:path=>"Константы",:descr=>"Тест Константы"},
    :Справочник => {:tmplts=>"Справочник.utest.epf",:path=>"Справочники",:descr=>"Тест справочника"},
    :Документ => {:tmplts=>"Документ.utest.epf",:path=>"Документы",:descr=>"Тест Документа"},
    :Перечисление => {:tmplts=>"Перечисление.utest.epf",:path=>"Перечисления",:descr=>"Тест Перечисления"},
    :Отчет => {:tmplts=>"Отчет.utest.epf",:path=>"Отчеты",:descr=>"Тест отчета"},
    :Обработка => {:tmplts=>"Обработка.utest.epf",:path=>"Обработки",:descr=>"Тест Обработки"},
    :ПланВидовХарактеристик=> {:tmplts=>"ПланВидовХарактеристик.utest.epf",:path=>"ПланыВидовХарактеристик",:descr=>"Тест Плана Видов Характеристик"},
#    :ПланСчетов => {:tmplts=>"ПланСчетов.utest.epf",:path=>"ПланыСчетов",:descr=>"Тест Плана Счетов"},
#    :ПланВидовРасчета => {:tmplts=>"ПланВидовРасчета.utest.epf",:path=>"ПланыВидовРасчета",:descr=>"Тест ПланыВидовРасчета"},
    :РегистрСведений => {:tmplts=>"РегистрСведений.utest.epf",:path=>"РегистрыСведений",:descr=>"Тест Регистра Сведений"},
    :РегистрНакопления => {:tmplts=>"РегистрНакопления.utest.epf",:path=>"РегистрыНакопления",:descr=>"Тест Регистра Накопления"},
#    :РегистрБухгалтерии => {:tmplts=>"РегистрБухгалтерии.utest.epf",:path=>"РегистрыБухгалтерии",:descr=>"Тест Регистра Бухгалтерии"},
#    :РегистрРасчета=> {:tmplts=>"РегистрРасчета.utest.epf",:path=>"РегистрыРасчета",:descr=>"Тест Регистра Расчета"},
    :БизнесПроцесс => {:tmplts=>"БизнесПроцесс.utest.epf",:path=>"БизнесПроцессы",:descr=>"Тест Бизнес Процесса"},
    :Задача => {:tmplts=>"Задача.utest.epf",:path=>"Задачи",:descr=>"Тест Задачи"},
    :ВнешнийИсточникДанных => {:tmplts=>"ВнешнийИсточникДанных.utest.epf",:path=>"ВнешниеИсточникиДанных",:descr=>"Тест Внешнего Источника Данных"}
  }
  
  def self.valid_mdname(mdname)
    raise "Имя объекта МД `#{mdname}' содержит запрещённые символы." if mdname =~ /(^[^a-zA-Zа-яА-Я]{1}|[^a-zA-Zа-яА-Я_0-9])/
  end
  
  def self.usage()
    UTESTS.sort.each do |k,v| 
      $stderr.puts "    #{k.to_s} - #{v[:descr]}" if File.exist?(testsourse(k))
    end
  end
  
  def self.valid_mdclass(mdclass)
    if ! UTESTS.has_key?(mdclass.to_sym) 
      $stderr.puts "Объект МД: '#{mdclass}` не поддерживается.
Доступные объекты МД:"
    Onedev_make_utest::usage
    abort
    end  
  end  
  
  def self.testsourse(mdclass)
    File.join(UTESTS_TMPLTS_PATH,"#{mdclass}.#{UTESTS_SUFF}")
  end   
  
  def self.get_testsourse(mdclass)
    testsourse = testsourse(mdclass)
    if ! File.exist?(testsourse)
       $stderr.puts "Тест для объекта МД: '#{mdclass}` не реализован в этой версии."
       abort
    end
    if File.exist?(testsourse) && ! File.file?(testsourse)
      raise "Шаблон теста #{testsourse} это каталог"
    end
    testsourse       
  end  
  
  def self.maketest_epf(testsourse,mdobject,class_dir,args)
  target = File.join(class_dir,"#{mdobject}.#{UTESTS_SUFF}")
    if File.exist?(target)
      $stderr.puts "Тест для объекта МД: '#{mdobject}` существует."
      abort
    end
    FileUtils.cp(testsourse,target) 
  end  
    
  def self.maketest(mdobject,path,args)
    mdclass = mdobject.split(".")[0].capitalize
    valid_mdname(mdclass)
    mdname = mdobject.split(".")[1].capitalize
    valid_mdname(mdname)
    valid_mdclass(mdclass)
    testsourse = get_testsourse(mdclass)
    class_dir = File.join(path,UTESTS_PATH,UTESTS[mdclass.to_sym][:path])
    FileUtils.mkdir_p(class_dir)
    maketest_epf(testsourse,mdobject,class_dir,args)
  end
  
end