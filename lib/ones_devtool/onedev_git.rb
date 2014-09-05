# encoding: utf-8
require 'git'
require 'logger'
require 'fileutils'
require 'tempfile'

module Onedev_git
  TAR_BIN = '/bin/tar'
  #Возвращает путь к выгруженному элементу path рабочего дерева git ревизии tree_ish
  #tree_ish - sha или tag
  def self.get_rev(tree_ish,path_)
    path = File.expand_path(`cygpath -u #{path_}`.chomp)
    system("tar --help 1>/dev/null")
    raise "Can't find `tar' command" if $?.exitstatus != 0 
    g = Git.open(get_gitindex(path))
    commit = vlid_commit(g.gcommit(tree_ish))
    $stdout.puts "Выгружаю ревизию `#{tree_ish}' объекта `#{path}'"
    arch_out = g.archive(tree_ish,nil,{:path=>path,:format=>'tar'})
    extract_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"#{File.basename(path)}.#{tree_ish}.#{Time.now.strftime('%M%S')}")
    FileUtils.mkdir_p(extract_path)
    err_out = File.join(ENV["TMP"],"#{Time.now.strftime('%s')}.tar.out")
    system("tar -xf #{arch_out} -C #{extract_path} 2>#{err_out}")
    raise "ERR: tar #{$?.to_s}: `#{File.open("#{err_out}"){|f| f.read}}'" if $?.exitstatus != 0
    return File.join(extract_path,File.basename(path))
  end
  
  private
  
  def self.vlid_commit(commit)
    commit.name
    return commit
  end
  
  def self.get_gitindex(path)
    if File.exist?(File.join(path,'.git'))
      return path
    else 
      path =~ /((?:[a-zA-Z]:)?\/)/
      if path == '.' || path== '/' || path==$1
        raise "Can't find `.gin'"  
      end
      return get_gitindex(File.dirname(path))  
    end
  end

end