# encoding: utf-8
require 'getoptlong'
module Onedev_dump
  COMMANDS = [:dump_infobase,:ibcf_tof,:ibcf_tocf,:dbcf_tocf,:dbcf_tof,:dissass_cf_tof]
  def self.getopt(command)
    opts = GetoptLong.new(
      [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
      [ '--version', '-v', GetoptLong::NO_ARGUMENT],
      [ '--file', '-F', GetoptLong::REQUIRED_ARGUMENT],
      [ '--server', '-S', GetoptLong::REQUIRED_ARGUMENT],
      [ '--name', '-N', GetoptLong::REQUIRED_ARGUMENT],
      [ '--password', '-P', GetoptLong::REQUIRED_ARGUMENT],
      [ '--dump_path', '-d', GetoptLong::REQUIRED_ARGUMENT],
      [ '--cf', '-c', GetoptLong::REQUIRED_ARGUMENT],
      [ '--dtf', '-D', GetoptLong::REQUIRED_ARGUMENT],
      [ '--force_clear', '-f', GetoptLong::NO_ARGUMENT],
      [ '--uc', '-u', GetoptLong::REQUIRED_ARGUMENT]
    )
     
  end
  
  def self.version
    puts "Версия утилиты: #{Version::VERSION}\nВерсия платформы: #{Ones_v8exe_wrapper.version}"
    abort
  end
  
  def self.conn_param()
    "-S | --server путь>      - путь подключения к серверной ИБ. Формат <host:port\/ibname>
    -F | --file <путь>       - путь к фаловой ИБ
    -N | --name <имя>        - имя пользователя ИБ
    -P | --password <пароль> - пароль пользователя ИБ
    -u | --uc <строка>       - код блокировки соединений с ИБ"
  end
    
  def self.command_usage(command)
   case command
     when :dump_infobase
    return "onedev-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] --dump_path <путь> --dtf <имя dt файла>
    Выгрузка данных ИБ в dt файл.
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    #{conn_param}
    -d | --dump_path <путь> - каталог выгрузки dt файла.
    -D | --dt <имя>    - имя dt файла."
     when :ibcf_tof
    return "onedev-dump-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--force_clear] --dump_path <путь>
    Выгрузка конфигурации ИБ в файлы XML. Для платформы >= 8.3.4
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    #{conn_param}
    -d | --dump_path <путь> - каталог xml файлов конфигурации
    --force_clear           - каталог --dump_path будет очищен принудительно"
     when :ibcf_tocf
    return "onedev-dump-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--force_clear] --dump_path <путь> --cf <имя cf файла>
    Выгрузка конфигурации ИБ в cf файл.
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    #{conn_param}
    -d | --dump_path <путь> - каталог выгрузки cf файла.
    -c | --cf <имя>    - имя cf файла
    --force_clear      - принудительно перезапишет --cf"
     when :dbcf_tof
    return "onedev-dump-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--force_clear] --dump_path <путь>
    Выгрузка конфигурации БД в файлы XML. Для платформы >= 8.3.4
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    #{conn_param}
    -d | --dump_path <путь> - каталог xml файлов конфигурации
    --force_clear           - каталог --dump_path будет очищен принудительно"
     when :dbcf_tocf
    return "onedev-dump-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--force_clear] --dump_path <путь> --cf <имя cf файла>
    Выгрузка конфигурации БД в cf файл.
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    #{conn_param}
    -d | --dump_path <путь> - каталог выгрузки cf файла.
    -c | --cf <имя>    - имя cf файла
    --force_clear      - принудительно перезапишет --cf"
     when :dissass_cf_tof
    return "onedev-dissass-cf-tof --cf <путь cf файла> --dump_path <путь> [--force_clear]
    Разбирает cf файл в файлы xml. Для платформы >= 8.3.4
    -v | --version     - версия
    -h | --help        - покажет это сообщение
    -c | --cf   <путь> - путь к cf файлу
    -d | --dump_path <путь> - каталог xml файлов конфигурации
    --force_clear           - каталог --dump_path будет очищен принудительно"
   end
  end
   
    
  def self.usage(command)
    $stderr.puts "#{command_usage(command)}"
    exit 1
  end
  
  def self.common_params(command,options)
    opts = getopt(command)
    common_param = {};
    opts.each do |opt, arg|
      case opt
        when '--help'
          usage(command)
        when '--version'
          version
        when '--server'
          common_param.update({:S=>arg})   
        when '--name'
          common_param.update({:N=>arg})   
        when '--password'
          common_param.update({:P=>arg})   
        when '--file'
          common_param.update({:F=>arg})   
        when '--uc'
          common_param.update({:UC=>arg})   
        when '--cf'
          options.update(:cf=>arg)
        when '--dtf'
          options.update(:dtf=>arg)
        when '--dump_path'
          options.update(:dump_path=>arg)
        when '--force_clear'  
          options.update(:force_clear=>true)
      end
    end
   if command != :dissass_cf_tof
     Ones_v8exe_wrapper.common_start_param(common_param) 
   else
     {}  
   end
  end
  
  def self.all_param?(command,common_params,options)
    if ! COMMANDS.include?(command)
      $stderr.puts "Не верная команда `#{command}'" 
      return false
    end
    # Обязательные параметры
    if command != :dissass_cf_tof && (! common_params.has_key?(:F) && ! common_params.has_key?(:S))
      $stderr.puts "Не установлен параметр -F или -S" 
      return false
    end
   
    if ! options.has_key?(:dump_path)
      $stderr.puts "Не установлен путь --dump_path" 
      return false
    end
    
    if (command == :dissass_cf_tof || command == :ibcf_tocf || command == :dbcf_tocf) && ! options.has_key?(:cf)
      $stderr.puts "Не установлен параметр --cf" 
      return false
    end

    if command == :dump_infobase && ! options.has_key?(:dtf)
      $stderr.puts "Не установлен параметр --dtf" 
      return false
    end
    return true
  end
  
  def self.exec(command,argv)
    options = {}
    begin
      common_params=common_params(command,options)
    rescue RuntimeError=>e
      $stderr.puts "ERR #{e.message}"
      usage(command)
    end
    
    if ! all_param?(command,common_params,options)
      usage(command)      
    end
          
   case command
      when :dump_infobase
        $stdout.puts "Выгружаю ИБ в файл `#{File.join(options[:dump_path],options[:dtf])}'"
        Ones_v8exe_wrapper.dump_ib(common_params,File.join(options[:dump_path],options[:dtf]))
      when :ibcf_tof
       $stdout.puts "Выгружаю конфигурацию ИБ в файлы `#{options[:dump_path]}'"
       Ones_v8exe_wrapper.dump_config_to_files(common_params,options[:dump_path],options[:force_clear])
     when  :dbcf_tof
       $stdout.puts "Выгружаю конфигурацию БД в файлы `#{options[:dump_path]}'"
       o_stderr = $stdout
       $stdout = File.open("/dev/nil",'w')
       Ones_v8exe_wrapper.dump_db_config_to_files(common_params,options[:dump_path],options[:force_clear])
       $stdout = o_stderr 
       $stdout.puts "Выгрузка конфигурации БД в файлы успешно завершена"
     when :ibcf_tocf
       $stdout.puts "Выгружаю конфигурацию ИБ в файл `#{File.join(options[:dump_path],options[:cf])}'"
       FileUtils.rm_f(File.join(options[:dump_path],options[:cf])) if File.exists?(File.join(options[:dump_path],options[:cf])) && options[:force_clear] 
       Ones_v8exe_wrapper.dump_cfg(common_params,File.join(options[:dump_path],options[:cf]))
     when :dbcf_tocf
       $stdout.puts "Выгружаю конфигурацию БД в файл `#{File.join(options[:dump_path],options[:cf])}'"
       FileUtils.rm_f(File.join(options[:dump_path],options[:cf])) if File.exists?(File.join(options[:dump_path],options[:cf])) && options[:force_clear] 
       Ones_v8exe_wrapper.dump_db_cfg(common_params,File.join(options[:dump_path],options[:cf]))
     when :dissass_cf_tof      
       $stdout.puts "Разбираю файл `#{options[:cf]}' в файлы `#{options[:dump_path]}'"
       o_stderr = $stdout
       $stdout = File.open("/dev/nil",'w')
       Ones_v8exe_wrapper.dissass_cf_to_files(options[:cf],options[:dump_path],options[:force_clear])
       $stdout = o_stderr 
       $stdout.puts "Разбор конфигурации в файлы успешно завершен"
    else
     $stderr.puts "Не верная команда `#{command}'" 
     exit 1    
    end
  end

end