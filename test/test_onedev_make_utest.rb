# encoding: utf-8
require 'test/unit'
require 'tempfile'
require_relative '../lib/ones_devtool/onedev_make_utest'
require_relative '../lib/ones_devtool/ones_mdscontainer'
require 'fileutils'

class Onedev_make_utestTest < Test::Unit::TestCase
  @@bin="./bin"
  def test_md_name_sub()
    assert_equal("mdclass.Имя", Onedev_make_utest.md_name_sub("mdclass","Имя"))
    assert_equal("mdclass", Onedev_make_utest.md_name_sub("mdclass",nil))
  end
  
  def test_valid_mdname
    valid_name="a2bcd_2edf1"
    Onedev_make_utest.valid_mdname(valid_name)
    assert_raise(RuntimeError) do
      Onedev_make_utest.valid_mdname("1#{valid_name}")
    end
    assert_raise(RuntimeError) do
      Onedev_make_utest.valid_mdname("#{valid_name}-gd")
    end
    assert_raise(RuntimeError) do
      Onedev_make_utest.valid_mdname("#{valid_name}?")
    end
  end
  
  def test_split_mdobject
    exp={:mdclass=>"Справочник",:mdname=>"Имя"}
    assert_equal(exp,Onedev_make_utest.split_mdobject("справочник.имя"))  
    exp={:mdclass=>"Роли",:mdname=>""}
    assert_equal(exp,Onedev_make_utest.split_mdobject("роли"))  
  end
  
  def test_get_mdclass_subs()
    exp = {:test_md_def_sub=>"function ТестЗаглушкаКонфигурации()\n raise \"FIXME В шаблоне отсутсвует реализация теста объекта МД\";\n endfunction",
    :test_md_call_sub=>"ТестЗаглушкаКонфигурации();",
    :md_name_sub=>"Конфигурация",
    :hase_ui_test_sub=>"Истина"
    }
    assert_equal exp, Onedev_make_utest.get_mdclass_subs("Конфигурация","")
    exp = {:hase_ui_test_sub=>"raise \"FIXME\"",
    :test_md_def_sub=>"function ТестЗаглушкаОбъектаМД()\n raise \"FIXME В шаблоне отсутсвует реализация теста объекта МД\";\n endfunction",
    :test_md_call_sub=>"ТестЗаглушкаОбъектаМД();",
    :md_name_sub=>"Справочник.Имя",
    }
    assert_equal exp, Onedev_make_utest.get_mdclass_subs("Справочник","Имя")
  end
  
  def test_substitude
    subs = {:hase_ui_test_sub=>"raise \"FIXME\"",
                    :test_md_def_sub=>"function ТестЗаглушкаОбъектаМД()\n raise \"FIXME В шаблоне отсутсвует реализация теста объекта МД\";\n endfunction",
                    :test_md_call_sub=>"ТестЗаглушкаОбъектаМД();",
                    :md_name_sub=>"Справочник.Имя"
                     }
    text = "hase_ui_test_sub\ntest_md_def_sub\ntest_md_call_sub\n\"md_name_sub\""
    exp_text= "raise \"FIXME\"\nfunction ТестЗаглушкаОбъектаМД()\n raise \"FIXME В шаблоне отсутсвует реализация теста объекта МД\";\n endfunction\nТестЗаглушкаОбъектаМД();\n\"Справочник.Имя\""
    assert_equal(exp_text,Onedev_make_utest.substitute(text,subs))
  end  
  
  def test_buldtest
    mdclass = :Справочник
    mdname = "ТестовыйСправочник"
    hash = Onedev_make_utest::UTESTS[mdclass]
    path = ENV["TMP"] 
    args={}
    
    utest_file = Onedev_make_utest.buldtest(mdclass,mdname,hash,path,args)
    assert_equal(true,File.exists?(utest_file))
    assert_equal(true,File.file?(utest_file))
        
    FileUtils.rm(utest_file)  
  end
  
  def test_capitalize
    assert_equal("Ай",Onedev_make_utest.capitalize("Ай"))
    assert_equal("Ай",Onedev_make_utest.capitalize("ай"))
  end
    
  def test_maketest
    mdobject = "Конфигурация"
    path = ENV["TMP"]
    args = {:verbose=>""}
    Onedev_make_utest.maketest(mdobject,path,args)
    Onedev_make_utest::UTESTS[:Конфигурация][:tmplts].each{|k,v|
      puts "test file exists #{File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","#{v[:path]}","#{k.to_s}.utest.epf")}"
      assert_equal(true,File.exists?(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","#{v[:path]}","#{k.to_s}.utest.epf")))
    } 
    Onedev_make_utest::UTESTS[:Конфигурация][:tmplts].each{|k,v|
      FileUtils.rm(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","#{v[:path]}","#{k.to_s}.utest.epf"))
    }
    
    mdobject = "справочник.тест"
    Onedev_make_utest.maketest(mdobject,path,args)
    assert_equal(true,File.exists?(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","Справочники","Справочник.Тест.utest.epf")))
    FileUtils.rm(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","Справочники","Справочник.Тест.utest.epf"))
    
    FileUtils.rm(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","ОбщиеМодули","ОбщийМодуль.Тест.utest.epf")) if File.exists?(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","ОбщиеМодули","ОбщийМодуль.Тест.utest.epf"))
    mdobject = "ОбщийМодуль.тест"
    Onedev_make_utest.maketest(mdobject,path,args)
    assert_equal(true,File.exists?(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","ОбщиеМодули","ОбщийМодуль.Тест.utest.epf")))
    FileUtils.rm(File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","ОбщиеМодули","ОбщийМодуль.Тест.utest.epf"))
  end 
  
  def test_onedev_make_utest
    mdobject = "справочник.тест"
    path = ENV["TMP"]
    args = {:verbose=>""}
    exp_file = File.join(path,"#{Onedev_make_utest::UTESTS_PATH}","Справочники","Справочник.Тест.utest.epf")  
    FileUtils.rm(File.join(path,exp_file)) if File.exists?(exp_file)
    system "#{@@bin}/onedev-make-utest --verbose #{mdobject} #{path}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(exp_file))
    FileUtils.rm(exp_file)
    
  end   
end
