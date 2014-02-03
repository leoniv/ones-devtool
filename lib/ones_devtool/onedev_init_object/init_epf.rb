# encoding: utf-8

module Onedev_init_object
module Init_epf
  BOM="\xEF\xBB\xBF"
  @res_path = File.join(File.dirname(__FILE__),File.basename(__FILE__,".rb"))
  
  def self.make_object(opt,path)
    
    source_path = @res_path+"/epftemplate.epf.src/"
    target_path = path+"/#{opt[:name]}.epf.src/"
    root_stream_target_path = "#{target_path}/7c97b4b2-86d5-45be-bd4a-2f98a8dca23f"
    module_target_path = "#{target_path}/97ecf9c0-3b63-4fcf-a433-bda251ed28ab.0/text"
      
    test_source_path = @res_path+"/test@epftemplate.epf.src/"
    test_target_path = path+"/test@#{opt[:name]}.epf.src/"

    
    rakefile_source = @res_path+"/Rakefile"        
    rakefile_target = path+"/Rakefile"        
 
    #Проверяем существование файлов
    abort "#{$0.split("/").last}: путь `#{path}' - это файл и он существует." if File.exists?(path) && File.file?(path)
    abort "#{$0.split("/").last}: каталог исходного кода `#{target_path}' - существует." if File.exists?(target_path)
    abort "#{$0.split("/").last}: каталог исходного кода `#{test_target_path}' - существует." if File.exists?(test_target_path)
    
    #Копируем
    FileUtils.mkdir_p(path)
    FileUtils.cp_r(source_path,target_path)
    FileUtils.cp_r(test_source_path,test_target_path)
    FileUtils.cp_r(rakefile_source,rakefile_target) unless File.exists?(rakefile_target)
    
    #Подстановки
    
    text=""
    File.open(root_stream_target_path, "r:bom|utf-8"){|file|
      text =  Onedev_init_object::subs(file.read,opt) 
     }
    File.open(root_stream_target_path,"w"){|f|
      f.write(BOM)
      f.write(text)
    }

    text=""
    File.open(module_target_path, "r:bom|utf-8"){|file|
      text =  Onedev_init_object::subs(file.read,opt) 
     }
    File.open(module_target_path,"w"){|f|
      f.write(BOM)
      f.write(text)
    }

    
  end
  
  def self.valid(opt)
     abort ":name содержит запрещённые символы \"#{opt[:name]}\"" if opt[:name] =~ /[^-0-9a-zA-z_.]/
     abort ":package содержит запрещённые символы \"#{opt[:package]}\"" if opt[:package] =~ /([\s]|[^-a-zA-Zа-яА-Я_.])/
     abort ":version содержит запрещённые символы \"#{opt[:version]}\"" if not opt[:version] =~ /^(\d)+[.](\d)+$/
     abort ":rel содержит запрещённые символы \"#{opt[:rel]}\"" if not opt[:rel] =~ /^(\d)+$/
   end

   def self.get_info(path)
     opt={:name=>"Имя_обработки",
      :human_name =>"Человекочитаемое имя",
      :copyright =>"Copyright © #{ Date.today.year.to_s} ...",
      :description =>"Описание",
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
"    epf - создаёт заготовку для разработки доп. обработки:
        * Каталог с разобранной обработкой ИмяОбъекта.epf.src
        * Каталог с разобранной обработкой тестирования доработок test@ИмяОбъекта.epf.src
        * Rackefile    
  " 
  end
   
   def self.init_object(args)
     get_info(args[:path])
   end

end
end