# encoding: utf-8
require 'getoptlong'

module Onedev_start
  
  def self.getopt(command)
    opts = GetoptLong.new(
      [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
      [ '--version', '-v', GetoptLong::NO_ARGUMENT],
      [ '--file', '-F', GetoptLong::REQUIRED_ARGUMENT],
      [ '--ws', '-W', GetoptLong::REQUIRED_ARGUMENT],
      [ '--server', '-S', GetoptLong::REQUIRED_ARGUMENT],
      [ '--name', '-N', GetoptLong::REQUIRED_ARGUMENT],
      [ '--password', '-P', GetoptLong::REQUIRED_ARGUMENT],
      [ '--ord_app', '-o', GetoptLong::NO_ARGUMENT],
      [ '--mng_app', '-m', GetoptLong::NO_ARGUMENT],
      [ '--debug', '-D', GetoptLong::NO_ARGUMENT],
      [ '--debugger_url', '-U', GetoptLong::REQUIRED_ARGUMENT],
      [ '--exec', '-e', GetoptLong::REQUIRED_ARGUMENT],
      [ '--cmd', '-C', GetoptLong::REQUIRED_ARGUMENT],
      [ '--uc', '-u', GetoptLong::REQUIRED_ARGUMENT],
      [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT]
    )
     
  end

  def self.version
    puts "Версия утилиты: #{Version::VERSION}\nВерсия платформы: #{Ones_v8exe_wrapper.version}"
    abort
  end
    
  def self.command_usage(command)
    case command
     when :disigner
      return "Запуск ИБ в конфигураторе"
     when :enterprise
      "Запуск ИБ в предприятии. Клиентское приложение определяется параметрами --ord_app будет запущен толстый клиент, --mng_app | -W - будет запущен тонкий клиент"
     when :testclient
       "Запуск ИБ как клиента тестирования"
     when :testmng
       "Запуск ИБ как менеджера тестирования"
    end
  end
  
  def self.enterprise_usage()
    "[--mng_app | --ord_app]"
  end

  def self.enterprise_args()
    "\n    -W | --ws <путь>         - путь подключения к ИБ через web сервер     
    -o | --ord_app      - режим запуска обычное приложение
    -m | --mng_app      - режим запуска управляемое приложение
    -e | --exec <путь>  - запуск внешней обработки в режиме 1С:Предприятие
    -C | --cmd <строка> - передача параметра в конфигурацию
    -D | --debug        - разрешение оладки в сеансе
    -U | --debugger_url <host> - адрес отладчика. По умолчанию localhost"
  end

  def self.testclient_args()
    "\n    -p | --port <port>  - порт клиента тестирования
    -e | --exec <путь>  - запуск внешней обработки в режиме 1С:Предприятие
    -C | --cmd <строка> - передача параметра в конфигурацию
    -D | --debug        - разрешение оладки в сеансе
    -U | --debugger_url <host> - адрес отладчика. По умолчанию localhost"
  end

  def self.testmng_args()
    "\n    -e | --exec <путь>  - запуск внешней обработки в режиме 1С:Предприятие
    -C | --cmd <строка> - передача параметра в конфигурацию
    -D | --debug        - разрешение оладки в сеансе
    -U | --debugger_url <host> - адрес отладчика. По умолчанию localhost"
  end
  
 
  def self.usage(command)
    $stderr.puts "onedev-start-#{command} -S | -F #{command == :enterprise ? "| -W" : ""} [-N] [-P] [--uc <строка>]#{command != :designer ? "[--debug] [--debuger_url <host>] [--exec <путь>] [--cmd <строка>]" : ""} #{command == :enterprise ? "#{enterprise_usage}" : ""} #{command == :testclient ? "[--port]" : ""}
    #{command_usage(command)}\n
    Параметры:
    -v | --version           - версия
    -h | --help              - покажет это сообщени   
    -S | --server путь>      - путь подключения к серверной ИБ. Формат <host:port\/ibname>
    -F | --file <путь>       - путь к фаловой ИБ
    -N | --name <имя>        - имя пользователя ИБ
    -P | --password <пароль> - пароль пользователя ИБ
    -u | --uc <строка>       - код блокировки соединений с ИБ#{command == :enterprise ? "#{enterprise_args}" : ""}"+"#{command == :testclient ? "#{testclient_args}" : ""}" + "#{command == :testmng ? "#{testmng_args}" : ""}"
    exit 1
  end
  
  def self.common_params(command)
    opts = getopt(command)
    common_param = {};
    case command
      when :testclient
        common_param.update({:TESTCLIENT=>{}})
      when :testmng
        common_param.update({:TESTMANAGER=>nil})
    end
    opts.each do |opt, arg|
      case opt
        when '--help'
          usage(command)
        when '--version'
          version
        when '--server'
          common_param.update({:S=>arg})   
        when '--ws'
          common_param.update({:WS=>arg})   
        when '--file'
          common_param.update({:F=>arg})   
        when '--name'
          common_param.update({:N=>arg})   
        when '--password'
          common_param.update({:P=>arg})   
        when '--ord_app'
          common_param.update({:RunModeOrdinaryApplication=>nil})   
        when '--mng_app'
          common_param.update({:RunModeManagedApplication=>nil})   
        when '--debug'
          common_param.update({:Debug=>nil})   
        when '--debugger_url'
          common_param.update({:DebuggerURL=>arg})   
        when '--exec'
          common_param.update({:Execute=>arg})   
        when '--cmd'
          common_param.update({:C=>arg})   
        when '--uc'
          common_param.update({:UC=>arg})   
        when '--port'
          common_param[:TESTCLIENT].update(:Port=>arg) if common_param.has_key?(:TESTCLIENT)   
      end
    end
    Ones_v8exe_wrapper.common_start_param(common_param)
  end
  
  def self.exec(command,argv)
    begin
      common_params=common_params(command)
    rescue RuntimeError=>e
      $stderr.puts "ERR #{e.message}"
      usage(command)
    end
    
    # Обязательные параметры
    if ! (common_params.has_key?(:F) || common_params.has_key?(:S) || common_params.has_key?(:WS))
      $stderr.puts "Не установлен параметр -S | -F" 
      usage(command)      
    end
    
    if common_params.has_key?(:Debug) && ! common_params.has_key?(:DebuggerURL)
      common_params.update(:DebuggerURL=>"localhost")
    end  
    
    case command
        when :disigner
          Ones_v8exe_wrapper.open_ib_designer(common_params)
        when :enterprise
          if common_params.has_key?(:RunModeManagedApplication)
            common_params.delete(:RunModeManagedApplication)
            tc=true
          elsif common_params.has_key?(:RunModeOrdinaryApplication)
            tc=false
          elsif common_params.has_key?(:WS)
              tc=true
          else
            tc=nil  
          end 
          Ones_v8exe_wrapper.open_ib_enterprise(common_params,tc)
      when :testclient
        Ones_v8exe_wrapper.open_ib_enterprise(common_params,true)
      when :testmng 
        Ones_v8exe_wrapper.open_ib_enterprise(common_params,true)
    end
  end
  
end