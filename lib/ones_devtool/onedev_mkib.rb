# encoding: utf-8
require 'getoptlong'
require 'git'
module Onedev_mkib
  
   
    def self.getopt(command)
      opts = GetoptLong.new(
        [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
        [ '--version', '-v', GetoptLong::NO_ARGUMENT],
        [ '--file', '-F', GetoptLong::REQUIRED_ARGUMENT],
        [ '--pattern_path', '-p', GetoptLong::REQUIRED_ARGUMENT],
        [ '--rev', '-r', GetoptLong::REQUIRED_ARGUMENT]
      )
       
    end
  
    def self.version
      puts "Версия утилиты: #{Version::VERSION}\nВерсия платформы: #{Ones_v8exe_wrapper.version}"
      abort
    end
      
    def self.command_usage(command)
      case command
       when :mkib
        return "Создание пустой ИБ"
       when :fromf
        "Создание ИБ из шаблона - xml фалов конфигурации. Если установлен --rev используются xml фалы указанной ревизии. Для платформы >= 8.3.4"
       when :fromcf
        "Создание ИБ из шаблона - cf фала."
       when :fromdt
        "Создание ИБ из шаблона - dt фала."
      end
    end
      
    def self.usage(command)
      $stderr.puts "onedev-mkib#{command=="mkib" ? "" : "-#{command}"} -F <путь> #{command == :fromf ? "[--rev <sha>]" : ""} #{command != :mkib ? " --pattern_path <путь шаблона>" : ""}
      #{command_usage(command)}
      -v | --version     - версия
      -h | --help        - покажет это сообщени
      -F | --file <путь> - путь для создоваемой фаловой ИБ"+"#{command == :fromf ? "\n      -r | --rev <sha>   - ревизия или метка git. ИБ будет создана из xml фалов ревизии <sha>" : ""}"+"#{command != :mkib ? "\n      -p | --pattern_path <путь шаблона> - путь к файлам шаблона" : ""}"
      exit 1
    end
    
    def self.get_rev(options)
      if options[:rev]
        return Onedev_git.get_rev(options[:rev],options[:pattern_path])
      end
        return options[:pattern_path]
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
          when '--file'
            common_param.update({:F=>arg})   
          when '--rev'
            options.update(:rev=>arg)
        when '--pattern_path'
            options.update(:pattern_path=>arg)
        end
      end
      Ones_v8exe_wrapper.common_start_param(common_param)
    end
    
    def self.all_param?(command,common_params,options)
      # Обязательные параметры
      if ! common_params.has_key?(:F)
        $stderr.puts "Не установлен параметр -F" 
        return false
      end
      
      if command != :mkib && ! options.has_key?(:pattern_path)
        $stderr.puts "Не указан путь <путь шаблона>" 
        return false
      end
      return true
    end
    
    def self.mkib(common_params,dtpath="")
      if common_params.has_key?(:F)
        Ones_v8exe_wrapper.mkinfobase_fs(common_params[:F],dtpath)
      elsif common_params.has_key?(:S)     
        Ones_v8exe_wrapper.mkinfobase_srv()
      end
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
        when :mkib
          mkib(common_params)
        when :fromf
          mkib(common_params)
          Ones_v8exe_wrapper.load_config_from_files(common_params,get_rev(options),true,false)
        when :fromcf
          mkib(common_params)
          Ones_v8exe_wrapper.load_cfg(common_params,options[:pattern_path])
          Ones_v8exe_wrapper.update_db_cfg(common_params)
        when :fromdt
          mkib(common_params,options[:pattern_path])
      end
    end
    
end