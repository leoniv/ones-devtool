# encoding: utf-8
require 'test/unit'
require 'digest/md5'
require 'tempfile'
require_relative '../lib/ones_devtool/ones_v8exe_wrapper'
require_relative '../lib/ones_devtool/ones_mdstream'
require 'fileutils'

class Ones_v8exe_wrapperTest < Test::Unit::TestCase
  @@resdir = "./test/ones_v8exe_wrapper.res/"
  def test0_Version()
    ENV.delete("ASSPATH");
    ENV.delete("ASSPLATFORM");
    FileUtils.mkdir_p(File.join(@@resdir,"8.2.12.42"))
    FileUtils.mkdir_p(File.join(@@resdir,"8.2.2.5"))
    ENV.update("ASSPATH"=>@@resdir);
    assert_equal("8.2.12.42",Ones_v8exe_wrapper.version());
    FileUtils.mkdir_p(File.join(@@resdir,"8.3.0.0"))
    assert_equal("8.3.0.0",Ones_v8exe_wrapper.version());
    ENV.update("ASSPLATFORM"=>"8.1.0.0");
    assert_equal("8.1.0.0",Ones_v8exe_wrapper.version());
    FileUtils.rm_r(File.join(@@resdir,"8.3.0.0"))
    FileUtils.rm_r(File.join(@@resdir,"8.2.12.42"))
    FileUtils.rm_r(File.join(@@resdir,"8.2.2.5"))
    ENV.delete("ASSPATH");
    ENV.delete("ASSPLATFORM");
  end

  def test0_eol_to_crlf
    file_path=Tempfile.new("txt").path;
    old_text = "строка1 \n строка2 \r\n\n\n\n Cтрока3 \n\n\n"
    exp_text="#{Ones_v8exe_wrapper::BOM}строка1 \r\n строка2 \r\n\r\n\r\n\r\n Cтрока3 \r\n\r\n\r\n"
    File.open(file_path,'w'){|f| 
      f.write(Ones_v8exe_wrapper::BOM)
      f.write(old_text)
    }
    assert_equal(exp_text,Ones_v8exe_wrapper.eol_to_crlf(file_path))
    FileUtils.rm_f(file_path) if File.exists?(file_path)
  end

  def test0_version_less_8_3_4()
    assert_equal(true,Ones_v8exe_wrapper.version_less_8_3_4("8.2.5"))
    assert_equal(true,Ones_v8exe_wrapper.version_less_8_3_4("8.3.3"))
    assert_equal(false,Ones_v8exe_wrapper.version_less_8_3_4("8.3.4"))
    assert_equal(false,Ones_v8exe_wrapper.version_less_8_3_4("8.3.5"))
    assert_equal(false,Ones_v8exe_wrapper.version_less_8_3_4("8.4.2"))
  end
  
  def test1_ones_v8exe()
    ENV.delete("ASSPATH");
    ENV.delete("ASSPLATFORM");

    FileUtils.rm_r(File.join(@@resdir,"1cv82")) if File.exists?(File.join(@@resdir,"1cv82"))
    FileUtils.rm_r(File.join(@@resdir,"1cv8")) if File.exists?(File.join(@@resdir,"1cv8"))
 
    FileUtils.mkdir_p(File.join(@@resdir,"1cv82/8.2.12.42"))
    FileUtils.mkdir_p(File.join(@@resdir,"1cv82/8.2.2.5"))
    FileUtils.mkdir_p(File.join(@@resdir,"1cv8/8.3.3.5"))
    FileUtils.mkdir_p(File.join(@@resdir,"1cv8/8.3.4.2"))
    
    pf = ENV["PROGRAMFILES"]
    ENV["PROGRAMFILES"]=@@resdir;
    assert_equal(File.join(@@resdir,"1cv8/8.3.4.2","bin","1cv8c.exe"),Ones_v8exe_wrapper.ones_v8exe(true))
    assert_equal(File.join(@@resdir,"1cv8/8.3.4.2","bin","1cv8.exe"),Ones_v8exe_wrapper.ones_v8exe())
 
    ENV["PROGRAMFILES"]=pf
    ENV.update("ASSPATH"=>File.join(@@resdir,"1cv82"));
    assert_equal(File.join(@@resdir,"1cv82","8.2.12.42","bin","1cv8c.exe"),Ones_v8exe_wrapper.ones_v8exe(true))
    assert_equal(File.join(@@resdir,"1cv82","8.2.12.42","bin","1cv8.exe"),Ones_v8exe_wrapper.ones_v8exe())

    FileUtils.rm_r(File.join(@@resdir,"1cv82")) if File.exists?(File.join(@@resdir,"1cv82"))
    FileUtils.rm_r(File.join(@@resdir,"1cv8")) if File.exists?(File.join(@@resdir,"1cv8"))
    ENV.delete("ASSPATH");
  end 

  def test2_lastout()
    s="СООБЩЕНИЕ НА РУССКОМ";
    FileUtils.touch(Ones_v8exe_wrapper::OUT_FILE_DEF)
    f = File.open(Ones_v8exe_wrapper::OUT_FILE_DEF,"w") do |f| 
      f.write(s.encode("cp1251"))
    end
    assert_equal(s,Ones_v8exe_wrapper.lastout(Ones_v8exe_wrapper::OUT_FILE_DEF))
    FileUtils.rm(Ones_v8exe_wrapper::OUT_FILE_DEF)    
  end
  
  def test3_common_param_to_s()
    hash = {
     :PAR1=>"Строка1", 
     :PAR2=>"Строка2", 
     :PAR3=>{:key1=>"Знач1",:key2=>"Знач2"},
     :PAR4=>nil,
    }
    str=" /PAR1\"Строка1\" /PAR2\"Строка2\" /PAR3 -key1\"Знач1\" -key2\"Знач2\" /PAR4"
    assert_equal(str,Ones_v8exe_wrapper.common_param_to_s(hash))
  end  
  
  def test4_common_start_param()
    hash={
      :F=>"path",
      :S=>"srv"
    }
    assert_raise(RuntimeError,"Должен быть только один параметр подключения /F | /S | /WS") do
      Ones_v8exe_wrapper.common_start_param(hash)
    end
    hash={
      :UC=>"path",
    }
    assert_raise(RuntimeError,"") do
      Ones_v8exe_wrapper.common_start_param(hash)
    end
    hash={
      :S=>"host:23\\ibname",
      :Out=>Ones_v8exe_wrapper::OUT_FILE_DEF,
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}  
    }
    assert_equal(hash,Ones_v8exe_wrapper.common_start_param({:S=>"host:23/ibname"}))
    hash={
      :F=>"path",
      :Out=>Ones_v8exe_wrapper::OUT_FILE_DEF,
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}  
    }
    assert_equal(hash,Ones_v8exe_wrapper.common_start_param({:F=>"path"}))
    hash={
      :WS=>"path",
      :Out=>Ones_v8exe_wrapper::OUT_FILE_DEF,
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}  
    }
    assert_equal(hash,Ones_v8exe_wrapper.common_start_param({:WS=>"path"}))
  end
  
  def test5_mkinfobase_fs()
    #Ограничения на путь
    ib_path = "/tmp/fucking-ones"
    assert_raise(RuntimeError) do
      Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
    end
    ib_path = "../fucking_ones"
    assert_raise(RuntimeError) do
      Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
    end
    #
    ib_path = File.join(@@resdir,"test_ib")
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    
    Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
    assert_equal(true,File.exists?(File.join(ib_path,"1Cv8.1CD")))
    
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
  end
 
  def test6_dump_ib_restore_ib()
  # Подготовка Создали ИБ
    ib_path = File.join(@@resdir,"test_ib")
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
    common_params = Ones_v8exe_wrapper.common_start_param({:F=>"#{ib_path}"})
  #   
    dump_path = File.join(@@resdir,"test_ib.dt")
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)

    Ones_v8exe_wrapper.dump_ib(common_params,dump_path)
    assert_equal(true,File.exists?(dump_path))

    Ones_v8exe_wrapper.restore_ib(common_params,dump_path)
    
    
        
  # Подготовка Удалили ИБ
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
  # Удаляем dump_path
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  end
  
  def test7_dump_cfg()
    # Подготовка Создали ИБ
      ib_path = File.join(@@resdir,"test_ib")
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
      Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
      common_params = Ones_v8exe_wrapper.common_start_param({:F=>"#{ib_path}"})
    #   
      dump_path = File.join(@@resdir,"test_ib.cf")
      FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  
      Ones_v8exe_wrapper.dump_cfg(common_params,dump_path)
      assert_equal(true,File.exists?(dump_path))
  
    # Подготовка Удалили ИБ
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    # Удаляем dump_path
      FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  end
  
  def test8_load_cfg_update_db_cfg()
    # Подготовка Создали ИБ
      ib_path = File.join(@@resdir,"test_ib")
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
      dump_db_cfg_path = File.join(@@resdir,"dump_db_cfg.cf")
      FileUtils.rm_r(dump_db_cfg_path) if File.exists?(dump_db_cfg_path)
      Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
      common_params = Ones_v8exe_wrapper.common_start_param({:F=>"#{ib_path}"})
    #   
      dump_path = File.join(@@resdir,"patterns","test_cf_pattern")
  
      Ones_v8exe_wrapper.load_cfg(common_params,dump_path)
      
      Ones_v8exe_wrapper.update_db_cfg(common_params,true,true)
      
      Ones_v8exe_wrapper.dump_db_cfg(common_params,dump_db_cfg_path)
      assert_equal(true,File.exists?(dump_db_cfg_path))
      
          
    # Подготовка Удалили ИБ
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    # Удалили dump_db_cfg_path
      FileUtils.rm_r(dump_db_cfg_path) if File.exists?(dump_db_cfg_path)
  end

  def test9_load_config_from_files_dump_config_to_files()
    # Подготовка Создали ИБ
      ib_path = File.join(@@resdir,"test_ib")
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
      pttern_dump_path = File.join(@@resdir,"patterns","test_cf_pattern.files")
      Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
      common_params = Ones_v8exe_wrapper.common_start_param({:F=>"#{ib_path}"})
    #   
      dump_path = File.join(@@resdir,"test_ib.files")
      FileUtils.rm_r(dump_path) if File.exists?(dump_path)
    # Загружаем конфигурацию из файлов без обновления конф БД
      Ones_v8exe_wrapper.load_config_from_files(common_params,pttern_dump_path)
    # Загружаем конфигурацию из файлов с обновлением конф БД
      Ones_v8exe_wrapper.load_config_from_files(common_params,pttern_dump_path,true,true,true)
    
    # Без очистки  dump_path    
      Ones_v8exe_wrapper.dump_config_to_files(common_params,dump_path,false)
      assert_equal(true,File.exists?(dump_path)&&File.directory?(dump_path))
    # C очисткой dump_path
      Ones_v8exe_wrapper.dump_config_to_files(common_params,dump_path,true)
      assert_equal(true,File.exists?(dump_path)&&File.directory?(dump_path))
  
    # Подготовка Удалили ИБ
      FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    # Удаляем dump_path
      FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  end
  
  def test99_dissass_cf_to_files()
    dump_path = File.join(@@resdir,"test_cf_pattern.files")
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)
    
    Ones_v8exe_wrapper.dissass_cf_to_files(File.join(@@resdir,"patterns","test_cf_pattern"),dump_path,true)
    assert_equal(true,File.exists?(dump_path)&&File.directory?(dump_path))
    
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  end  

  def test999_assemble_cf_to_files()
    cf_path = File.join(@@resdir,"test_cf_pattern.cf")
    FileUtils.rm_r(cf_path) if File.exists?(cf_path)
     
    Ones_v8exe_wrapper.assemble_cf_from_files(cf_path,File.join(@@resdir,"patterns","test_cf_pattern.files"))
    assert_equal(true,File.exists?(cf_path)&&File.file?(cf_path))
    
    FileUtils.rm_r(cf_path) if File.exists?(cf_path)
  end  
  
  def test9999_dump_db_config_to_files()
    # Подготовка Создали ИБ
    ib_path = File.join(@@resdir,"test_ib_dump_db_config_to_files")
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    dump_path = File.join(@@resdir,"test_ib_dump_db_config_to_files.files")
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)
    Ones_v8exe_wrapper.mkinfobase_fs(ib_path)
    common_params = Ones_v8exe_wrapper.common_start_param({:F=>"#{ib_path}"})
    # Загрузили в test_ib кофигурацию test_cf_pattern и обновили конф БД
    Ones_v8exe_wrapper.load_cfg(common_params,File.join(@@resdir,"patterns","test_cf_pattern"))
    Ones_v8exe_wrapper.update_db_cfg(common_params,true,true)
    #
    Ones_v8exe_wrapper.dump_db_config_to_files(common_params,dump_path,true)
    assert_equal(true,File.exists?(dump_path)&&File.directory?(dump_path))
    
    #Очистка  
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
    FileUtils.rm_r(dump_path) if File.exists?(dump_path)
  end
     
end  