# encoding: utf-8
require 'yaml'
require 'fileutils'

module Onedev_init_object
@init_commands = {:lib=>Init_lib, :cf=>Init_cf}
 
  def self.usage()
    @init_commands.each(){|key, value| $stderr.puts value.send(:usage)}
  end
  
  def self.init_object(command,args)
    if @init_commands.has_key?(command)
      @init_commands[command].send(:init_object,args) 
    else
      $stderr.puts "Неизвестная команда '#{command}`"
    end   
  end
  
  def self.get_pkgname(path)
    pkgname_f = File.join(path,"pkgname") 
    if File.exists?(pkgname_f) && File.file?(pkgname_f) then
      text = File.open(pkgname_f, "r:bom|utf-8").readlines[0]
      text.gsub!(/\r?\n?/, "")
      text
    else
      "Установите знчение по образцу(org.example.lib.common)"
    end    
  end 
  
  def self.subs(text,subs)
    subs.each{|key,value| text.gsub!(/#{key.to_s}_sub/,value)}
    text  
  end     
  
end

begin
   Dir.glob( File.join( File.dirname( __FILE__ ), "**", "*.rb" ) ).each { |l| require l }
 rescue LoadError => e
   $sdterr.puts( e.message )
end
