# encoding: utf-8

module Onedev_init_object
module Init_cf
  BOM="\xEF\xBB\xBF"
  @res_path = File.join(File.dirname(__FILE__),File.basename(__FILE__,".rb"))

  
  def self.make_object(opt,path)
    
    update_source_path = @res_path+"/update@template.epf.src/"
    update_target_path = path+"/update@#{opt[:name]}.epf.src/"
    update_module_target_path = "#{update_target_path}/549e8d36-dd6a-44de-b042-0c93641397c5.0/text"
      
    test_source_path = @res_path+"/test@template.epf.src/"
    test_target_path = path+"/test@#{opt[:name]}.epf.src/"

    root_mod_source_path = @res_path+"/root_mod_template.txt"
    root_mod_target_path = path+"/root_mod_#{opt[:name]}.txt"
    
    rakefile_source = @res_path+"/Rakefile"        
    rakefile_target = path+"/Rakefile"        
 
    #Проверяем существование файлов
    abort "#{$0.split("/").last}: путь `#{path}' - это файл и он существует." if File.exists?(path) && File.file?(path)
    abort "#{$0.split("/").last}: каталог исходного кода `#{update_target_path}' - существует." if File.exists?(update_target_path)
    abort "#{$0.split("/").last}: каталог исходного кода `#{test_target_path}' - существует." if File.exists?(test_target_path)
    abort "#{$0.split("/").last}: файл `#{root_mod_target_path}' - существует." if File.exists?(root_mod_target_path)
    
    #Копируем
    FileUtils.mkdir_p(path)
    FileUtils.cp_r(update_source_path,update_target_path)
    FileUtils.cp_r(test_source_path,test_target_path)
    FileUtils.cp_r(root_mod_source_path,root_mod_target_path)
    FileUtils.cp_r(rakefile_source,rakefile_target) unless File.exists?(rakefile_target)
    
    #Подстановки
    
    text=""
    File.open(update_module_target_path, "r:bom|utf-8"){|file|
      text =  Onedev_init_object::subs(file.read,opt) 
     }
    File.open(update_module_target_path,"w"){|f|
      f.write(BOM)
      f.write(text)
    }

    text=""
    File.open(root_mod_target_path, "r:bom|utf-8"){|file|
      text =  Onedev_init_object::subs(file.read,opt) 
     }
    File.open(root_mod_target_path,"w"){|f|
      f.write(BOM)
      f.write(text)
    }

    
  end

  def self.valid(opt)
    abort ":package содержит запрещённые символы \"#{opt[:package]}\"" if opt[:package] =~ /[^-0-9a-zA-z_.]/
    abort ":name содержит запрещённые символы \"#{opt[:name]}\"" if opt[:name] =~ /([\s]|[^a-zA-Zа-яА-Я_])/
    abort ":version содержит запрещённые символы \"#{opt[:version]}\"" if not opt[:version] =~ /^(\d)+[.](\d)+$/
#    abort ":rel содержит запрещённые символы \"#{opt[:rel]}\"" if not opt[:rel] =~ /^(\d)+$/
  end
 
  
  def self.get_info(path)
    opt={
     :package=>Onedev_init_object::get_pkgname(path),
     :name    =>"Имя_узла(правки)",
     :version =>"1.0",
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
"    cf - создаёт заготовку для разработки доработки конфигурации поставщика:
        * Файл ИмяОбъекта_root_mod.txt - код корневого модуля доработки
        * Каталог с разобранной обработкой тестирования доработок test@ИмяОбъекта.epf.src
        * Каталог с разобранной обработкой установки доработок update@ИмяОбъекта.epf.src
        * Rackefile    
  " 
  end
   
   def self.init_object(args)
     get_info(args[:path])
   end
end
end
