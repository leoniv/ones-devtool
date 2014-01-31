# encoding: utf-8

module Onedev_init_object
  module Init_lib
    BOM="\xEF\xBB\xBF"
    @res_path = File.join(File.dirname(__FILE__),File.basename(__FILE__,".rb"))
    
    def self.make_object(opt,path)
      obj_module=path+"/#{opt[:name]}.epf.src/97ecf9c0-3b63-4fcf-a433-bda251ed28ab.0/text"
      obj_root  =path+"/#{opt[:name]}.epf.src/7c97b4b2-86d5-45be-bd4a-2f98a8dca23f"
  
      name_sub = "libtemplate"
      human_name_sub = "Шаблон подключаемой библиотеки"
      description_sub = "Описание"
      
      #Проверяем существование объектов
      abort "#{$0.split("/").last}: путь `#{path}' - это файл и он существует." if File.exists?(path) && File.file?(path)
      abort "#{$0.split("/").last}: каталог исходного кода объекта `#{path+"/#{opt[:name]}.epf.src"}' - существует." if File.exists?(path+"/#{opt[:name]}.epf.src")
      abort "#{$0.split("/").last}: каталог исходного кода объекта `#{path+"/test@#{opt[:name]}.epf.src"}' - существует." if File.exists?(path+"/test@#{opt[:name]}.epf.src")

      FileUtils.mkdir_p(path)
      
      # Копируем файлы
      FileUtils.cp_r("#{@res_path}/libtemplate.epf.src",path+"/#{opt[:name]}.epf.src")
      FileUtils.cp_r("#{@res_path}/libtests.epf.src",path+"/test@#{opt[:name]}.epf.src")
      FileUtils.cp_r("#{@res_path}/Rakefile",path+"/")
      
      
      #Читаем root
      root_stream=""
      File.open(obj_root, "r:bom|utf-8"){|file|
        root_stream = file.read
       }
      root_stream.sub!(/"#{name_sub}"/){|s|
        "\""+opt[:name]+"\""
      }
      root_stream.sub!(/#{human_name_sub}/){|s|
        opt[:human_name]
      }
      root_stream.sub!(/#{description_sub}/){|s|
        opt[:description]
      }
      File.open(obj_root,"w"){|f|
        f.write(BOM)
        f.write(root_stream)
      }
      module_stream = ""
      File.open(obj_module, "r:bom|utf-8"){|file|
        module_stream = file.read
       }
      module_stream.gsub!(/version=\s*"[0-9]+[.][0-9]+"\s*[;]?\s*$/i){|s|
        puts "Get version: #{s}"
        "version=\"#{opt[:version]}\";"
      }
      module_stream.gsub!(/rel=\s*"[0-9]+"\s*[;]?\s*$/i){|s|
        puts "Get rel: #{s}"
        "rel=\"#{opt[:rel]}\";"
      }
      module_stream.gsub!(/package=\s*"[-a-zA-Zа-яА-Я_.]*"\s*[;]?\s*$/i){|s|
        puts "Get pakage: #{s}"
        "package=\"#{opt[:package]}\";"
      }
      module_stream.gsub!(/[$]Copyright[\s]*$/i){|s|
        puts "Get copy: #{s}"
        "Copyright (c) #{Time.now.strftime('%Y')} #{opt[:copyright]}" if opt[:copyright].length>0
      }
        module_stream.gsub!(/[$]Description[\s]*$/i){|s|
          puts "Get Desc: #{s}"
          "#{opt[:description]}" if opt[:description].length>0
        }
          module_stream.gsub!(/[$]Support[\s]*$/i){|s|
            puts "Get supp: #{s}"
            supp="#{opt[:site]}\n" if opt[:site].length>0
            supp+="//  E-mail: #{opt[:email]}" if opt[:email].length>0
            supp  
          }
       File.open(obj_module,"w"){|f|
         f.write(BOM)
         f.write(module_stream)
         }
    end
    
    def self.valid(opt)
      abort ":name содержит запрещённые символы \"#{opt[:name]}\"" if opt[:name] =~ /([\s]|[^a-zA-Zа-яА-Я_])/
      abort ":package содержит запрещённые символы \"#{opt[:package]}\"" if opt[:package] =~ /([\s]|[^-a-zA-Zа-яА-Я_.])/
      abort ":version содержит запрещённые символы \"#{opt[:version]}\"" if not opt[:version] =~ /^(\d)+[.](\d)+$/
      abort ":rel содержит запрещённые символы \"#{opt[:rel]}\"" if not opt[:rel] =~ /^(\d)+$/
    end

    def self.get_info(path)
      opt={:name=>"Имя_объекта(библиотеки)",
       :human_name =>"Человекочитаемое имя",
       :copyright =>"",
       :description =>"Краткое Описание",
       :email      =>"e-mail@support",
       :site        =>"http://project",
       :version     =>"1.0",
       :rel         =>"0",
       :package     =>Onedev_init_object::get_pkgname(path)
      }.to_yaml
      tmp = "#{ENV['TMP']}/opt.yaml"
      opt="#Заполните значения свойств нового объекта\n"+opt
      File.open(tmp,"w"){|f|f.write(opt)}
      system("$EDITOR #{tmp}")
      opt_new = YAML.load(File.open(tmp,"r").read())
      valid opt_new
      puts "Будет создан объект со следующими свойствами:"
      puts "#{opt_new.to_yaml}\nПродолжить?[Y/N]"
      
      $stdin.each{|line|
        unless line =~ /^(Y|y|N|n)$/
          puts "Yes или No [Y/N]"
        else
          make_object opt_new,path if line =~ /^(Y|y|)$/
          puts "By..."
          exit 
        end
      }  
    end


 
  def self.usage()
"    lib - создаёт заготовку для разработки общей библиотеки
        * Каталог с разобранной обработкой, отчетом ИмяОбъекта.epf(erf).src
        * Каталог с разобранной обработкой тестирования объекта test@ИмяОбъекта.epf.src
        * Rackefile 
"   
  end
  
  def self.init_object(args)
    get_info(args[:path])
   end
  
    
    
end 
end