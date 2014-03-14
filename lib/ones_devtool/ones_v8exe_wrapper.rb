# encoding: utf-8
require 'fileutils'
class Ones_v8exe_wrapper
  BOM="\xEF\xBB\xBF"
  #Класс обёртка для 1cv8.exe
  OUT_FILE_DEF="#{File.join(ENV['temp'].gsub(/\\/){|s| s='/'},"ones_v8exe_wrapper.#{Time.now.strftime("%Y_%d_%m_%H_%M_%S")}.out")}"
  DUMPRES_FILE_DEF="#{File.join(ENV['temp'].gsub(/\\/){|s| s='/'},'ones_v8exe_wrapper.dump_result')}"
  COMMON_START_PARAM={
    :F=>"<Путь>", 
    :S=>'<host:port\IBName>',
    :WS=>"http://host:port/path", 
    :N=>"<Имя пользователя ИБ>",
    :P=>"<Пароль пользователя ИБ>",
    :WSN=>"Имя пользователя для аутентификации на веб-сервере",
    :WSP=>"Пароль пользователя для аутентификации на веб-сервере",
    :Out=>"<Путь>",
    :C=>"<Параметры запуска>",
    :DisableStartupDialogs=>nil,
    :DisableStartupMessages=>nil, 
    :AllowExecuteScheduledJobs=>{:Off=>nil,:Force=>nil}, #-Off ИЛИ -Force 
    :RunModeOrdinaryApplication=>nil,
    # ИЛИ 
    :RunModeManagedApplication=>nil,
    :UC=>"<Код блокиовки ИБ>", 
    :NoProxy=>nil,
    :Proxy=>{:PSrv=>"<Адрес прокси>",:PPort=>"<Порт прокси>",:PUser=>"<Пользователь прокси>",:PPwd=>"<Пароль прокси>"},
    :Debug=>nil,
    :DebuggerURL=>"<URL отладчика>", 
    :Execute=>"<Имя файла внешней обработки>", 
    :TESTMANAGER=>nil,
    :TESTCLIENT=>{:TPort=>"<Порт>"},
    :UILOGRECORDER=>{:TPort=>"<Порт>",:File=>"<Файл>"},
    :Z=>"<Общий реквизит 1>,<Общий реквизит 2>,...,<Общий реквизит N>",
    :itdi=>nil,
    # ИЛИ
    :isdi=>nil,
    :iTaxi=>nil,
# Далее параметры конфигуратора
    :Visible=>nil,
  }
  
  #возвращает используемую версию 1cv8.exe. 
  #По умолчанию ищет максимальную установленную. 
  #Можно заставить использовать версию установив переменную ASSPLATFORM
  def self.version()
    if ENV.has_key?("ASSPLATFORM") then
      ENV["ASSPLATFORM"]
    else
      max_assver(asspath())
    end      
  end
  
  #Возвращает полный путь к 1cv8.exe указанной версии.
  #Ищет платформу 1С в %PROGRAMFILES%/1cv8
  #Можно заставить искать платформу в другом месте
  #установив пепременную %ASSPATH%
  def self.ones_v8exe(thin=false)
    tc=thin ? "c" : ""
    result = File.join(asspath,version(),"bin","1cv8#{tc}.exe")
  end
  
  #возвращает последнее сообщение 1cv8.exe записанное в файл /Out
  def self.lastout(outfile)
    File.open(outfile,:encoding=>"cp1251"){|f| f.read.encode("utf-8")} if File.exist?(outfile) && File.file?(outfile) 
  end
  
  #Проверяет hash на соответсвие
  #общим параметрам запуска 1cv8.exe
  #добавляет знач по умолчанию
  def self.common_start_param(hash=nil)
    if hash == nil
      hash = {:F=>""};
    end  
    hash.each(){|key,value|
      raise "Неизвесный параметр `#{key}'" if ! COMMON_START_PARAM.has_key?(key)
      case COMMON_START_PARAM[key].class.to_s
        when "Array"
          raise "Не верное значение параметра `#{value}'" if ! COMMON_START_PARAM[key].include?(value)
        when "Hash"
          if COMMON_START_PARAM[key].class != value.class
            raise "Не верный тип значения параметра`#{key}'. Ожидалось `#{COMMON_START_PARAM[key].class}' имеем `#{value.class}'"
          end  
          value.each() do |_key,_value|
            raise "Не верное значение ключа `#{_key}' параметра `#{value}'" if ! value.has_key?(_key)
          end    
        when "NilClass"
            value=nil         
        when String
            
      end
   }
  #Обязательные Исключающие параметры /F,/S,/WS
   conn_param = 0;
   conn_param+= 1 if hash.has_key?(:F)
   conn_param+= 1 if hash.has_key?(:S)
   conn_param+= 1 if hash.has_key?(:WS)
   raise "Должен быть один параметр подключения к ИБ <F> | <S> | <WS>" if conn_param != 1
  #Параметр /S приводим к виду host:port\ibname
  if hash.has_key?(:S)
    raise "Параметр <S> должен иметь вид `host:port/ibmane'" unless hash[:S] =~ /([\w\d\-]+[:0-9]*[\/][\w\d\-]+)/ && $1 == hash[:S]
    hash.update(:S=>hash[:S].gsub(/\//){|s| s = "\\"})
  end

  #Значения по умолчанию /Out
   hash.update(:Out=>OUT_FILE_DEF) if ! hash.has_key?(:Out) 
  #Значеник по умолчанию /DisableStartupDialogs
   hash.update(:DisableStartupDialogs=>nil) if ! hash.has_key?(:DisableStartupDialogs)
  #Значеник по умолчанию /DisableStartupMessages
   hash.update(:DisableStartupMessages=>nil) if ! hash.has_key?(:DisableStartupMessages) 
  #Значеник по умолчанию /AllowExecuteScheduledJobs
  hash.update(:AllowExecuteScheduledJobs=>{:Off=>nil}) if ! hash.has_key?(:AllowExecuteScheduledJobs)
  hash.clone
  end
 
  #создаёт файловую ИБ
  def self.mkinfobase_fs(path,pattern="")
    pattern =  File.exists?(pattern) && File.file?(pattern) ? "/UseTemplate \"#{pattern}\"" : ""
    path=path.gsub(/\\/){|s| s='/'}
    raise "Путь существует" if File.exists?(path)
    FileUtils.mkdir(path)
    raise "Путь -F `#{path}' не должен содержать символы '-' (тире). Причина: fucking 1C" if path =~ /-/
    raise "Относительный путь -F `#{path}' не может ссылатся на родительский каталог '../'. Причина: fucking 1C" if path =~ /\.{2}\//
    path = `cygpath -w #{path}`.chomp
    FileUtils.rm(OUT_FILE_DEF) if File.exists?(OUT_FILE_DEF)  
    system "\"#{ones_v8exe()}\" CREATEINFOBASE File=\"#{path}\" #{pattern} /Out\"#{OUT_FILE_DEF}\""
    if $?.exitstatus != 0 then
       raise "ERR Создание информационной базы `#{$?.to_s}' \n #{lastout(OUT_FILE_DEF)}"
    else
       $stdout.puts lastout(OUT_FILE_DEF)
       reg = "Создание информационной базы \\\(\\\"File=#{path.gsub(/\\/){|s| s='\\\\'}.gsub(/\./){|s| s='\.'}}.*?успешно завершено"
       raise "ERR Создание информационной базы\n #{lastout(OUT_FILE_DEF)}" unless lastout(OUT_FILE_DEF)=~ /#{reg}/ 
       #Создание информационной базы ("File=.\test\ones_v8exe_wrapper.res\tets_ib ;Locale = "ru_RU";") 
    end
    FileUtils.rm(OUT_FILE_DEF) if File.exists?(OUT_FILE_DEF)  
  end
  
  #создаёт ИБ на сервере
  def self.mkinfobase_srv() 
    raise "TODO"
  end

  #выгрузить ИБ в файл
  def self.dump_ib(common_params,dump_path)
    raise "Файл существует `#{dump_path}'" if File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /DumpIB\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Выгрузка информационной базы `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
      raise "ERR Выгрузка информационной базы\n #{lastout(common_params[:Out])}" unless lastout(common_params[:Out])=~ /Выгрузка информационной базы успешно завершена/ 
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end
  
  #загрузить ИБ из файла  
  def self.restore_ib(common_params,dump_path)
    raise "Файл не существует `#{dump_path}'" if ! File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /RestoreIB\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Загрузка информационной базы `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
      raise "ERR Загрузка информационной базы\n #{lastout(common_params[:Out])}" unless lastout(common_params[:Out])=~ /Загрузка информационной базы успешно завершена/ 
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end

  #выгружает конфигурацию ИБ в cf файл
  def self.dump_cfg(common_params,dump_path)
    raise "Файл существует `#{dump_path}'" if File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /DumpCfg\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Выгрузка конфигурации инф. базы `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
      raise "ERR Выгрузка конфигурации инф. базы\n #{lastout(common_params[:Out])}" unless lastout(common_params[:Out])=~ /Сохранение конфигурации успешно завершено/ 
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end
  
  #загружает конфигурацию ИБ из cf файла 
  def self.load_cfg(common_params,dump_path)
    raise "Файл не существует `#{dump_path}'" if ! File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /LoadCfg\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Загрузка конфигурации инф. базы `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
      raise "ERR Загрузка конфигурации инф. базы\n #{lastout(common_params[:Out])}" unless lastout(common_params[:Out])=~ /Загрузка конфигурации успешно завершена/ 
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end
    
  #обновление конфигурации базы данных
  def self.update_db_cfg(common_params,warnings_as_errors=false,server=false)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    update_db_cfg_options = warnings_as_errors ? " -WarningsAsErrors " : "" 
    update_db_cfg_options = "#{update_db_cfg_options} #{server ? " -Server " : ""}" 
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /UpdateDBCfg #{update_db_cfg_options} /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Oбновление конфигурации базы данных `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      lustout_ = lastout(common_params[:Out])
      lustout_ = lustout_.length == 0 ? "Обновление конфигурации базы данных успешно завершено" : lustout_
      $stdout.puts "#{lustout_}"
      raise "ERR Oбновление конфигурации базы данных\n #{lustout_}" unless lustout_ =~ /Обновление конфигурации (базы данных )?успешно завершено/
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end

  #выгружает конфигурацию БД в cf файл
  def self.dump_db_cfg(common_params,dump_path)
    raise "Файл существует `#{dump_path}'" if File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /DumpDBCfg\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Выгрузка конфигурации базы данных `#{$?.to_s}`\n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
      raise "ERR Выгрузка конфигурации базы данных\n #{lastout(common_params[:Out])}" unless lastout(common_params[:Out])=~ /Сохранение конфигурации успешно завершено/ 
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end

  
  #выгружает конфигурацию ИБ в файлы - только для платформы >= 8.3.4
  def self.dump_config_to_files(common_params,dump_path,force_clear)
    raise "Выгрузка конфигурации в файлы возможна для платформы >= 8.3.4" if version_less_8_3_4(version())
    raise "Путь выгрузки `#{dump_path}' это файл." if File.exists?(dump_path) && File.file?(dump_path)
    raise "Каталог существует `#{dump_path}'. Для очистки установите аргумент `force_clear'" if File.exists?(dump_path) && ! force_clear
    if File.exists?(dump_path) && force_clear
    #Очищаем каталог dump_path
      FileUtils.rm_r(Dir.glob(File.join(dump_path,"*")))  
    end   
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /DumpConfigToFiles\"#{dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Выгрузка конфигурации в файлы `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      normalize_eol(dump_path)
      $stdout.puts "Выгрузка конфигурации ИБ в файлы успешно завершена\n#{lastout(common_params[:Out])}"
      raise "ERR Выгрузка конфигурации в файлы\nКаталог выгрузки `#{dump_path}' не обнаружен\n #{lastout(common_params[:Out])}" unless File.exists?(dump_path)&&File.directory?(dump_path)
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
  end

  #загружает конфигурацию ИБ из файлов - только для платформы >= 8.3.4
  def self.load_config_from_files(common_params,dump_path,update_db_cfg=false,warnings_as_errors=false,server=false)
    raise "Загрузка конфигурации из файлов возможна для платформы >= 8.3.4" if version_less_8_3_4(version())
    raise "Путь загрузки `#{dump_path}' это файл." if File.exists?(dump_path) && File.file?(dump_path)
    raise "Каталог загрузки `#{dump_path}' не существует." if ! File.exists?(dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    #Копируем xml dump_path
    copy_dump_path = `cygpath.exe -m #{File.join(ENV["TMP"],"copy_dump_#{Time.now.strftime("%Y_%d_%m_%H_%M_%S")}")}`.chomp
    FileUtils.mkdir(copy_dump_path)
    FileUtils.cp(Dir.glob(File.join(dump_path,"*")),copy_dump_path)
    #Прячем файлы на которых спотыкается загрузка
    stash_dump_path = File.join(copy_dump_path,"stash")
    FileUtils.mkdir(stash_dump_path)
    FileUtils.mv(Dir.glob(File.join(copy_dump_path,"CommonForm.*.Form.*")),stash_dump_path)
    FileUtils.mv(Dir.glob(File.join(copy_dump_path,"*.Form.*.Form.*")),stash_dump_path)
    FileUtils.mv(Dir.glob(File.join(copy_dump_path,"Role.*.Rights.xml")),stash_dump_path)
    FileUtils.mv(Dir.glob(File.join(copy_dump_path,"CommonTemplate.*.Template.xml")),stash_dump_path)
    FileUtils.mv(Dir.glob(File.join(copy_dump_path,"*.Template.*.Template.*")),stash_dump_path)
    #Выполняем первый проход
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /LoadConfigFromFiles\"#{copy_dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    #Возвращаем файлы в каталог xml дампа
    FileUtils.mv(Dir.glob(File.join(stash_dump_path,"*")),copy_dump_path)
    #Выполняем второй проход
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /LoadConfigFromFiles\"#{copy_dump_path}\" /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      FileUtils.rm_r(copy_dump_path)
      raise "ERR Загрузка конфигурации из файлов `#{$?.to_s}'\n #{lastout(common_params[:Out])}"
    else
      $stdout.puts "Загрузка конфигурации из файлов успешно завершена\n#{lastout(common_params[:Out])}"
     end
    FileUtils.rm_r(copy_dump_path)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    if update_db_cfg 
      update_db_cfg(common_params,warnings_as_errors,server)
    end  
  end
  
  
  
  #Разбирает конфигурацию из cf файл в xml файлы - только для платформы >= 8.3.4
  def self.dissass_cf_to_files(cf_path,dump_path,force_clear)
    raise "Разбор cf в файлы возможен для платформы >= 8.3.4" if version_less_8_3_4(version())
    #1) Создаём пустую ИБ во временном каталоге
    ib_path = File.join(ENV["temp"],"infobase_#{Time.now.strftime("%Y_%d_%m_%H_%M_%S")}_tmp")
    common_params = common_start_param({:F=>ib_path}) 
    mkinfobase_fs(ib_path)
    #2) Загружаем cf_path в ИБ
    load_cfg(common_params,cf_path)
    #3) Выгружаем Конфигурацию ИБ в файлы
    dump_config_to_files(common_params,dump_path,force_clear)
    #4) Очистка
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
  end
  
  #Собирает конфигурацию из xml файлы в cf файл 
  def self.assemble_cf_from_files(cf_path,dump_path)
    raise "Сборка cf из файлов возможна для платформы >= 8.3.4" if version_less_8_3_4(version())
    #1) Создаём пустую ИБ во временном каталоге
    ib_path = File.join(ENV["temp"],"infobase_#{Time.now.strftime("%Y_%d_%m_%H_%M_%S")}_tmp")
    common_params = common_start_param({:F=>ib_path}) 
    mkinfobase_fs(ib_path)
    #2) Загружаем файлы dump_path в ИБ
    load_config_from_files(common_params,dump_path,false,false,false)
    #3) Выгружаем Конфигурацию ИБ в cf_path 
    dump_cfg(common_params,cf_path)
    #4) Очистка
    FileUtils.rm_r(ib_path) if File.exists?(ib_path)
  end
  
  #выгружает конфигурацию БД целевой ИБ в файлы - только для платформы >= 8.3.4
  #common_params - параметры подключения к ИБ
  def self.dump_db_config_to_files(common_params,dump_path,force_clear)
    raise "Выгрузка конфигурации в файлы возможна для платформы >= 8.3.4" if version_less_8_3_4(version())
    #1) Выгружаем конф БД в tmp.cf
    tmp_cf_path = File.join(ENV["temp"],"infobase_#{Time.now.strftime("%Y_%d_%m_%H_%M_%S")}_tmp")
    dump_db_cfg(common_params,tmp_cf_path)
    #2) Разбираем cf в файлы
    dissass_cf_to_files(tmp_cf_path,dump_path,force_clear)
    #3) Очистка удаляем tmp.cf
    FileUtils.rm_r(tmp_cf_path) if File.exists?(tmp_cf_path)
  end
  
  
  #Открываем в конфигураторе
  def self.open_ib_designer(common_params)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe()}\" DESIGNER #{common_param_to_s(common_params)} /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Запуск 1С:Конфигуратор `#{$?.to_s}' \n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end  

  #Открываем в предприятии
  def self.open_ib_enterprise(common_params,thin_client=false)
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)
    system "\"#{ones_v8exe(thin_client)}\" ENTERPRISE #{common_param_to_s(common_params)} /DumpResult\"#{DUMPRES_FILE_DEF}\""
    if $?.exitstatus != 0 then
      raise "ERR Запуск 1С:Предприятие `#{$?.to_s}'\n #{lastout(common_params[:Out])}"
    else
      $stdout.puts lastout(common_params[:Out])
    end
    FileUtils.rm(common_params[:Out]) if File.exists?(common_params[:Out])  
    FileUtils.rm(DUMPRES_FILE_DEF) if File.exists?(DUMPRES_FILE_DEF)  
  end  

    
  private
  
  def self.version_less_8_3_4(version)
   if version.split('.')[0].to_i<8 
     true
   elsif version.split('.')[0].to_i>8
     false 
   else
     if version.split('.')[1].to_i<3
      true
     elsif version.split('.')[1].to_i>3
      false 
     else
       if version.split('.')[2].to_i<4 
         true
       else
         false  
       end    
     end   
   end     
  end  
  
  def self.asspath
    if ENV.has_key?("ASSPATH") then
      raise "Каталог установки платформы 1С `#{ENV["ASSPATH"]}' не обнаружен" unless File.exists?(ENV["ASSPATH"])
      ENV["ASSPATH"]
    else
      ass_path = File.join(ENV["PROGRAMFILES"].gsub(/\\/){|s| s="/"},"1cv8")
      raise "Каталог установки платформы 1С `#{ass_path}' не обнаружен" unless File.exists?(ass_path)
      ass_path
    end      
  end  
  
  def self.max_assver(path)
    versions = Dir.glob(File.join(path,"8.*"))
    raise "В каталоге `#{path}' нет установленных версий платформы 1С" if versions.length == 0
    versions.map{ |v| (File.basename(v).split '.').collect(&:to_i) }.max.join '.'
  end  

def self.common_param_to_s(hash)
   result=""
   hash.each(){|key,value|
     case value.class.to_s
       when "String"
        result = "#{result} /#{key.to_s}\"#{value.to_s}\""
       when "Hash"
         result = "#{result} /#{key.to_s}"
         value.each{|_key,_value|
          result = "#{result} -#{_key.to_s}\"#{_value.to_s}\""
          }
       when "NilClass"   
        result = "#{result} /#{key.to_s}"
     end
       
     }
     result
 end
 

 #Приводим конец строки к \r\n
 #При выгрузке конфигурации в файлы полатформа
 #Как попало вставляет концы строк
 def self.normalize_eol(dir)
   Dir.glob(File.join(dir,"*")).each{|f| eol_to_crlf(f)}
 end

 #Приводим конец строки к \r\n
 #При выгрузке конфигурации в файлы полатформа
 #Как попало вставляет концы строк
 def self.eol_to_crlf(file_path)
   result = ""
   if Ones_mdstream.text_file?(file_path)
     File.open(file_path, "r:bom|utf-8"){|file|
     result = "#{BOM}#{file.read.gsub(/(?<!\r)\n{1}/){|s| s="\r\n"}}"
     }
     File.open(file_path, "w"){|file|
       file.write(result)
     }
     result
   end
end
  
end