# encoding: utf-8
require 'fileutils'
require 'ones_devtool/ones_mdstream'
# Файл контейнер 1C metadata-stream
# Файл *.cf  - содержит  конфигурацию 1С
# Файл *.epf - содержит внешнюю обоаботку
# Файл *.erf - содержит внешний отчет
# В контейнер входят фалы metadata-stream + файлы двоичных данных
# Формат контейнера - проприетарный 1С
class Ones_mdscontaiter
  @@MAGIC="\xFF\xFF\xFF\x7F"
  @@ENDBLOCK=""
  #Версия использует утилиту v8unpack.exe
  def self.disassemble(file_path,dir_path)
    test_binary
    if not container?(file_path)
      raise "Файл #{file_path} не является контейнером 1C meta-data stream"
    end 
    #Очищаем каталог
    FileUtils.rm_rf(Dir.glob(dir_path+"/*"));
    system "v8unpack.exe -P #{file_path} #{dir_path}" 
    if $? == 0
      count = 0
      findfiles(dir_path){|f|
        Ones_mdstream.write_mdsfile(f,(Ones_mdstream.pretty_stream((Ones_mdstream.read_mdsfile(f)),true)))
      }
    else
      raise "Dissasseble ERROR"  
    end
  end
  
  #Версия использует утилиту v8unpack.exe
  def self.assemble(dir_path,file_path)
    #Надо копировать и приводить у исходному копию и её-же собирать
    test_binary
    tmp_path="./assemble.tmp"
    Dir.mkdir(tmp_path) if not Dir.exist?(tmp_path)
    FileUtils.copy_entry(dir_path,tmp_path) 
    findfiles(tmp_path){|f|
      Ones_mdstream.write_mdsfile(f,(Ones_mdstream.unpretty_stream(Ones_mdstream.read_mdsfile(f))))
    }
    system "v8unpack.exe -B  #{tmp_path} #{file_path}"
    FileUtils.rm_rf(tmp_path)
  end

  def self.container?(file_path)
    bufer=nil
    File.open(file_path){|f|
      bufer = f.read(4)
    }
    bufer.dump == @@MAGIC.dump
  end
   
  protected
  def self.test_binary
    ext_dir = File.expand_path('../../../ext/v8unpack/', __FILE__)
   # puts "Path = #{ext_dir}"
    v8unpack=ext_dir+'/v8unpack.exe'
    zlib=ext_dir+'/zlib1.dll'
    bin_root='/usr/local/bin/'  
    if not File.exist?(bin_root+'v8unpack.exe')
      FileUtils.cp(v8unpack,bin_root)
      FileUtils.chmod 0755 , bin_root+'v8unpack.exe'
    end
    if not File.exist?(bin_root+'zlib1.dll')
      FileUtils.cp(zlib,bin_root+'zlib1.dll')
    end
  end

  def self.findfiles(dir_path,&closure)
    Dir.glob(dir_path+"/*").each{|entry|
    if File.directory?(entry)
      findfiles(entry,&closure)
    else   
      yield entry  
    end
    }
  end
end