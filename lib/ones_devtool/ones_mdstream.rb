# Класс реализуе работу с потоком 1C metadata-stream (1c mds)
# Формат потока {,{"это стока"},1}
# По сути 1C mds - это сериализованный массив где элементы массива отделены
# запятыми. Каждый массив завёрнут в скобки { и }. Типы данных:
# - nil - пустое значение
# - "[^$.]*" - строка символов
# - [1-9]*   -  целое число
# - [a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12} - GUID
# - @@SIZELIMIT - ограничение на чтение файла потока большого размера (на 30M падает regex)
#   скорее всего это BASE64 объект и хрен на него
class Ones_mdstream
  @@SIZELIMIT=2**22
  @@BOM="\xEF\xBB\xBF"
  @@ZERRO="\x00\x00\x00\x00"
  public
  #Принимает аргумент <stream> - текст в формате 1С metadata-stream (1C mds)
  #Возвращает форматированный для человеческого восприятия и
  #удобный для управления в системе контроля версий текст.
  #Правила форматирования
  # - каждый элемент массива располагается в новой строке
  #   вместе со своей ведущей запятой перевод строки.
  # - если shift=true форматировать отступами: кажда открывающая скобка - 
  #   увеличивает отступ на n пробелов каждая закрывающая фигурная скобка -
  #   уменьшает отступ на n пробела
  def self.pretty_stream(stream,shift=false,n=1)
    if is_mdstream?(stream)
      pretty(stream,shift,n)
    else
      stream
    end
  end
  
  def self.unpretty_stream(stream)
    if is_mdstream?(stream)
      unpretty(stream)
    else
      stream
    end
  end

  
  protected
 
  def self.read_mdsfile(path)
    stream = "" 
    if text_file?(path)
      File.open(path, "r:bom|utf-8"){|file|
         stream = file.read
        stream = "" if not is_mdstream?(stream)
        stream
      } if File.size(path)<=@@SIZELIMIT
    end 
    stream
  end

  def self.write_mdsfile(path,stream)
    result=0
    File.open(path, "w"){|file|
      result = file.write(@@BOM)
      result += file.write(stream)
    } if is_mdstream?(stream)
    result
  end

  private
    @@EOL="\r\n"
    def self.unpretty(stream)
      stream.gsub!(/^[\s]+/){|s|
        ""
        }  
      stream.gsub!(/#{@@EOL},/){|s|
        ","
        }  
    end  

  def self.pretty(stream,shift,n)
    stream.gsub!(/,[^,^$.]*/){|s|
      @@EOL+s
      }
    #Отступы
    if shift
      sh_cnt=0   
      stream.gsub!(/^(.)*$/){|s|
          sn = (" "*n)*sh_cnt+s
          sh_cnt+=(s.scan(/{/).length - s.scan(/}/).length)
          sn
      }
    end
    stream      
  end
    
  def self.pretty_old(stream,shift)
    #Удаляем начальные пробелы
    stream.gsub!(/^\s*/){|c|
      ""
    }
    #Удаляем концы строк
    stream.delete!("\r\n")
    #Рааставляем переносы
    stream.gsub!(/[{}]/){|c|
      if c[0]=="{"
        "\r\n{"
      else
        "\r\n}"
      end
    }
    #Отступы
    if shift
      count = -1;
      stream.gsub!(/^\S/){|c|
        if c[0]=="{"
          count+=1
          " "*count+"{"
        elsif c[0]=="}"
          count-=1
          " "*(count+1)+"}"
        else
          " "*(count>0 ? count : 0)+c[0].to_s
        end
      }
    end
    stream
  end
  #=begin
  #Возвращает истину если первый значащий символ "{"
  #=end
  def self.is_mdstream?(stream)
    result=false
    if stream[0..3].dump != @@ZERRO.dump then
      result = (stream.strip =~ /^[{]+/) !=nil
    end
  end
  def self.text_file?(path)
    bufer=nil
    File.open(path){|f|
      bufer = f.read(4)
    }
    bufer.dump != @@ZERRO.dump
  end  
end