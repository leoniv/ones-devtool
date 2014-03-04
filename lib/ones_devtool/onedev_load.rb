# encoding: utf-8
require 'getoptlong'
module Onedev_load
  COMMANDS=[:assemble_cf_fromf,:ibcf_fromf,:dbcf_fromf,:ibcf_fromcf,:dbcf_fromcf]
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
      [ '--rev', '-r', GetoptLong::REQUIRED_ARGUMENT],
      [ '--force', '-f', GetoptLong::NO_ARGUMENT],
      [ '--warn_as_err', '-w', GetoptLong::NO_ARGUMENT],
      [ '--on_server', '-s', GetoptLong::NO_ARGUMENT],
      [ '--uc', '-u', GetoptLong::REQUIRED_ARGUMENT],
      [ '--assemble_path', '-a', GetoptLong::REQUIRED_ARGUMENT]  
    )
     
  end
  
  def self.version
    puts "Версия утилиты: #{Version::VERSION}\nВерсия платформы: #{Ones_v8exe_wrapper.version}"
    abort
  end
  
  def self.conn_script_param()
    "-S | --server путь>      - путь подключения к серверной ИБ. Формат <host:port\/ibname>
    -F | --file <путь>       - путь к фаловой ИБ
    -N | --name <имя>        - имя пользователя ИБ
    -P | --password <пароль> - пароль пользователя ИБ
    -u | --uc <строка>       - код блокировки соединений с ИБ"
  end

  def self.comm_script_param()
    "-v | --version     - версия
    -h | --help        - покажет это сообщение"
  end
    
  def self.command_usage(command)
   case command
    when :assemble_cf_fromf
    return "onedev-#{command} [--rev <sha>] --dump_path <путь> --assemble_path <путь> --сf <имя cf файла>
    Собирает сf файл из файлов xml кофигурации. Если установлен --rev используются xml фалы указанной ревизии. Для платформы >= 8.3.4
    #{comm_script_param}
    -d | --dump_path <путь> - каталог xml файлов конфигурации
    -a | --assemble_path <путь> - каталог где будет размещен собранный cf файл
    -r | --rev <sha>   - ревизия или метка git 
    -c | --cf <имя>    - имя cf файла"

    when :ibcf_fromf
    return "onedev-load-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--rev <sha>] --dump_path <путь>
    Загрузка конфигурации ИБ из файлов XML. Если установлен --rev используются xml фалы указанной ревизии. Для платформы >= 8.3.4
    #{comm_script_param}
    #{conn_script_param}
    -r | --rev <sha>   - ревизия или метка git 
    -d | --dump_path <путь> - каталог xml файлов конфигурации"

    when :dbcf_fromf
    return "onedev-load-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--warn_as_err] [--on_server] [--rev <sha>] --dump_path <путь> --force
    Загрузка конфигурации БД из файлов XML. Если установлен --rev используются xml фалы указанной ревизии. Для платформы >= 8.3.4
    !!! ВНИМАНИЕ ОПЕРАЦИЯ НОСИТ НЕОБРАТИМЫЙ ХАРАКТЕР !!!
    #{comm_script_param}
    #{conn_script_param}
    -r | --rev <sha>   - ревизия или метка git 
    -d | --dump_path <путь> - каталог xml файлов конфигурации
    -w | --warn_as_err - все предупредительные сообщения будут трактоваться как ошибки
    -s | --on_server   - обновление будет выполняться на сервере (имеет смысл только в клиент-серверном варианте работы)
    --force            - без этого аргумента скрипт завершится с ошибкой"
 
    when :ibcf_fromcf
    return "onedev-load-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] --cf <путь>
    Загрузка конфигурации ИБ из cf файла.
    #{comm_script_param}
    #{conn_script_param}
    -c | --cf <путь> - путь к cf файлу"
   
    when :dbcf_fromcf
    return "onedev-load-#{command} -F <путь> | -S <путь> [-N <имя> [-P <пароль>]] [--uc <строка>] [--warn_as_err] [--on_server] --cf <путь> --force
    Загрузка конфигурации БД из cf файла.
    !!! ВНИМАНИЕ ОПЕРАЦИЯ НОСИТ НЕОБРАТИМЫЙ ХАРАКТЕР !!!
    #{comm_script_param}
    #{conn_script_param}
    -c | --cf <путь> - путь к cf файлу
    -w | --warn_as_err - все предупредительные сообщения будут трактоваться как ошибки
    -s | --on_server   - обновление будет выполняться на сервере (имеет смысл только в клиент-серверном варианте работы)
    --force            - без этого аргумента скрипт завершится с ошибкой"
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
        when '--assemble_path'
          options.update(:assemble_path=>arg)
        when '--dump_path'
          options.update(:dump_path=>arg)
        when '--force'  
          options.update(:force=>true)
        when '--rev'  
          options.update(:rev=>arg)
        when '--warn_as_err'  
          options.update(:warn_as_err=>true)
        when '--on_server'  
          options.update(:on_server=>true)
      end
    end
   if command != :assemble_cf_fromf
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
    if command != :assemble_cf_fromf && (! common_params.has_key?(:F) && ! common_params.has_key?(:S))
      $stderr.puts "Не установлен параметр -F или -S" 
      return false
    end
   
    if (command == :assemble_cf_fromf || command == :ibcf_fromf || command == :dbcf_fromf) && ! options.has_key?(:dump_path)
      $stderr.puts "Не установлен путь --dump_path" 
      return false
    end
    
    if (command == :assemble_cf_fromf || command == :ibcf_fromcf || command == :dbcf_fromcf) && ! options.has_key?(:cf)
      $stderr.puts "Не установлен параметр --cf" 
      return false
    end

    if (command == :dbcf_fromcf || command == :dbcf_fromf) && ! options.has_key?(:force)
      $stderr.puts "!!! ВНИМАНИЕ ОПЕРАЦИЯ НОСИТ НЕОБРАТИМЫЙ ХАРАКТЕР !!! для подтверждения установите ключ --force" 
      return false
    end
    
    if command == :assemble_cf_fromf && ! options.has_key?(:assemble_path)
      $stderr.puts "Не установлен параметр --assemble_path" 
      return false
    end
    
    return true
  end

  def self.get_rev(options)
    if options[:rev]
      return Onedev_git.get_rev(options[:rev],options[:dump_path])
    end
      return options[:dump_path]
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
      when :assemble_cf_fromf
      $stdout.puts "Собираю файл `#{File.join(options[:assemble_path],options[:cf])}' из `#{options[:rev] ? "#{options[:rev]} -- " : "" }#{options[:dump_path]}'"
      o_stdout = $stdout
      $stdout = File.open("/dev/nil",'w')
      Ones_v8exe_wrapper.assemble_cf_from_files(File.join(options[:assemble_path],options[:cf]),get_rev(options))
      $stdout = o_stdout 
      $stdout.puts "Сборка файла успешно завершена"
     when :ibcf_fromf
      $stdout.puts "Загружаю конф. ИБ из фалов `#{options[:rev] ? "#{options[:rev]} -- " : "" }#{options[:dump_path]}'"
      Ones_v8exe_wrapper.load_config_from_files(common_params,get_rev(options),false)
     when :dbcf_fromf
      $stdout.puts "Загружаю конф. БД из фалов `#{options[:rev] ? "#{options[:rev]} -- " : "" }#{options[:dump_path]}'"
      o_stdout = $stdout
      $stdout = File.open("/dev/nil",'w')
      Ones_v8exe_wrapper.load_config_from_files(common_params,get_rev(options),true,options[:warn_as_err],options[:on_server])
      $stdout = o_stdout 
      $stdout.puts "Загрзка конфигурации БД успешно завершена"
    when :dbcf_fromcf 
      $stdout.puts "Загружаю конф. БД из фала `#{options[:cf]}'"
      o_stdout = $stdout
      $stdout = File.open("/dev/nil",'w')
        Ones_v8exe_wrapper.load_cfg(common_params,options[:cf])
        Ones_v8exe_wrapper.update_db_cfg(common_params)
      $stdout = o_stdout 
      $stdout.puts "Загрзка конфигурации БД успешно завершена"
    when :ibcf_fromcf 
      $stdout.puts "Загрзка конфигурации ИБ из фала `#{options[:cf]}'"
        Ones_v8exe_wrapper.load_cfg(common_params,options[:cf])
    end
  end

  
end