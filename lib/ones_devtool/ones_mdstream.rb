# Класс реализуе работу с потоком 1C metadata-stream (1c mds)
# Формат потока {,{"это стока"},1}
# По сути 1C mds - это сериализованный массив где элементы массива отделены
# запятыми. Каждый массив завёрнут в скобки { и }. Типы данных:
# - nil - пустое значение
# - /(?<=^|{|,)\s*(?<=[^"])"(?=[^"]).*?(?<=[^"])"(?=[^"])/mi - строка символов заключена в "" в нутри строки символ " = ""
# - /(?<=^|{|,)[-]?[0-9]+(?=,|}|$)/m  -  целое число
# - 00010101000000 - похоже на флаги (14 разрядов ???)
# - /((?<={|,)\s*[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}(?=,|}|$)/m - GUID
# - /(?<=^|{|,)\s*#base64:[a-zA-Z0-9+\/=\s]*/mi - двоичные данные base64
#@@SIZELIMIT - ограничение на чтение файла потока большого размера (на 30M падает regex)
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
  #   уменьшает отступ на n пробела работает очень криво т.к в тексте
  #   потока может быть текст модуля ня ЯП 1С в комметариях котрого
  #   вполне может быть любое количество симвлов { или }
  #   это обстоятельство сильно осложняет разбор потока на
  #   уровни вложенности с тспользованием regex.
  def self.pretty_stream(stream,shift=false,n=1)
    if is_mdstream?(stream)
      pretty(stream,shift,n)
    else
      stream
    end
  end
  
  #Принимает аргумент <stream> - текст в формате 1С metadata-stream (1C mds)
  #форматированный функцией pretty_stream и удаляет форматирование
  #приводя поток к первоначальному сосьоянию
  #un_shift - работает так-же криво как и в pretty_stream 
  def self.unpretty_stream(stream,un_shift=false,n=1)
    if is_mdstream?(stream)
      unpretty(stream,un_shift,n)
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
  def self.unpretty(stream,un_shift,n)
      sh_cnt=0 
      if un_shift  
        stream.gsub!(/^(.)*$/){|s|
          sn = s[0,n*sh_cnt].strip+s[n*sh_cnt,s.length]
          raise "Unsifted not empty: #{s[0,n*sh_cnt].strip} sn=#{sn}" if s[0,n*sh_cnt].strip.length>0
          sh_cnt+=(s.scan(/{/).length - s.scan(/}/).length)
          sn
      }
      end
     stream.gsub!(/#{@@EOL},/){|s|
        ","
        }  
  end  
  
  def self.pretty(stream,shift,n)
    stream.gsub!(/,/){|s|
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
    
  #=begin
  #Возвращает истину если первый значащий символ "{"
  #=end
  def self.is_mdstream?(stream)
    result=false
     result = ((stream.lstrip.lines.to_a[0] =~ /^[{]+/) != nil)
    result
  end
  def self.text_file?(path)
    bufer=nil
    File.open(path){|f|
      bufer = f.read(3)
    }
    not (bufer.dump != @@BOM.dump)
  end  
end