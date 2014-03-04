require 'test/unit'
require_relative '../lib/ones_devtool/onedev_load'
require_relative '../lib/ones_devtool/ones_v8exe_wrapper'
require 'fileutils'
class TestOnedevLoad < Test::Unit::TestCase
  @@resdir = "./test/onedev_load.res/"
  @@bindir = "./bin"
  def test_common_param
    commands=[:assemble_cf_fromf,:ibcf_fromf,:dbcf_fromf,:ibcf_fromcf,:dbcf_fromcf]
        
    assert_equal(commands,Onedev_load::COMMANDS)  
   
    argv()
     
    exp_common_params={
     }
    exp_options = {
      :dump_path=>"dump/path",
      :rev=>"rev_sha",
      :cf=>"cf/path",
      :force=>true,
      :assemble_path=>"assemble/path",
      :warn_as_err=>true,
      :on_server=>true
    }
    options={}
    common_params=Onedev_load.common_params(:assemble_cf_fromf,options)
    assert_equal(exp_common_params,common_params)
    assert_equal(exp_options,options)

    argv()
    
    exp_common_params={
      :S=>"host:232\\ibname",
      :N=>"uname",
      :P=>"pass",
      :UC=>"uc str",
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}
    }

    options={}
    common_params=Onedev_load.common_params(:ibcf_fromf,options)
    common_params.delete(:Out)
    assert_equal(exp_common_params,common_params)
    assert_equal(exp_options,options)
    
    #all_param?(command,common_params,options) :S or :F
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))
    common_params.delete(:S)
    assert_equal(false,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))

    #all_param?(command,common_params,options) :dump_path
    common_params.update(:F=>"path")
    options.delete(:dump_path)  
    assert_equal(false,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
    
    #all_param?(command,common_params,options) :cf
    options.update(:dump_path=>"dump/path")
    options.delete(:cf)
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
    
    #all_param?(command,common_params,options) :force
    options.update(:cf=>"cf/path")
    options.delete(:force)  
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    
    #all_param?(command,common_params,options) :assemble_path
    options.update(:force=>true)
    options.delete(:assemble_path)  
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromf,common_params,options))
    assert_equal(false,Onedev_load.all_param?(:assemble_cf_fromf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:ibcf_fromcf,common_params,options))
    assert_equal(true,Onedev_load.all_param?(:dbcf_fromcf,common_params,options))
  end
  
  def test_load_all
    #Создали временную ИБ
    tmp_ib_path = File.join(ENV["temp"].gsub(/\\/){|s| s="/"},"tmpib")
    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "tar -xf #{File.join(@@resdir,"tmpib.tar")} -C #{ENV["temp"].gsub(/\\/){|s| s="/"}}"       
    #Создали временный git
    tmp_git_repo = File.join(ENV["temp"].gsub(/\\/){|s| s="/"},"tmpib.gitrepo")
    FileUtils.rm_r(tmp_git_repo) if File.exists?(tmp_git_repo)
    FileUtils.mkdir(tmp_git_repo)
    system "tar -xf #{File.join(@@resdir,"git.tar")} -C #{tmp_git_repo}"
    
    #:assmble-cf-from
    assemble_path = ENV["temp"].gsub(/\\/){|s| s="/"}
    cf = "tmpib.cf"
    FileUtils.rm_r(File.join(assemble_path,cf)) if File.exists?(File.join(assemble_path,cf))
    system "#{@@bindir}/onedev-assemble-cf-fromf --dump_path #{File.join(tmp_git_repo,'git','tmpib.cf.files')} --assemble_path #{assemble_path} --cf #{cf}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(assemble_path,cf)))
    FileUtils.rm_r(File.join(assemble_path,cf)) if File.exists?(File.join(assemble_path,cf))
    system "#{@@bindir}/onedev-assemble-cf-fromf --rev v1.0.0.2 --dump_path #{File.join(tmp_git_repo,"git","tmpib.cf.files")} --assemble_path #{assemble_path} --cf #{cf}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(assemble_path,cf)))
          
    #:ibcf-fromcf
    system "#{@@bindir}/onedev-load-ibcf-fromcf -F #{tmp_ib_path} --cf #{File.join(assemble_path,cf)}"
    assert_equal(0,$?.exitstatus)
    #:dbcf-fromcf   
    system "#{@@bindir}/onedev-load-dbcf-fromcf -F #{tmp_ib_path} --cf #{File.join(assemble_path,cf)} --force"
    assert_equal(0,$?.exitstatus)
    #:ibcf-fromf
    system "#{@@bindir}/onedev-load-ibcf-fromf -F #{tmp_ib_path} --dump_path #{File.join(tmp_git_repo,'git','tmpib.cf.files')}"
    assert_equal(0,$?.exitstatus)
    system "#{@@bindir}/onedev-load-ibcf-fromf -F #{tmp_ib_path} --dump_path #{File.join(tmp_git_repo,'git','tmpib.cf.files')} --rev v1.0.0.2"
    assert_equal(0,$?.exitstatus)
    #:dbcf-fromf   
    system "#{@@bindir}/onedev-load-dbcf-fromf -F #{tmp_ib_path} --dump_path #{File.join(tmp_git_repo,'git','tmpib.cf.files')} --force"
    assert_equal(0,$?.exitstatus)
    system "#{@@bindir}/onedev-load-dbcf-fromf -F #{tmp_ib_path} --dump_path #{File.join(tmp_git_repo,'git','tmpib.cf.files')} --rev v1.0.0.2 --force"
    assert_equal(0,$?.exitstatus)
    
    
    
    #Очистили     
    FileUtils.rm_r(tmp_git_repo) if File.exists?(tmp_git_repo)
    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
  end
  
  private
    def argv
      ARGV<<"-S"
      ARGV<<"host:232/ibname"
      ARGV<<"-N"
      ARGV<<"uname"
      ARGV<<"-P"
      ARGV<<"pass"
      ARGV<<"--uc"
      ARGV<<"uc str"
      ARGV<<"--dump_path"
      ARGV<<"dump/path"
      ARGV<<"--cf"
      ARGV<<"cf/path"
      ARGV<<"--rev"
      ARGV<<"rev_sha"
      ARGV<<"--force"
      ARGV<<"--assemble_path"
      ARGV<<"assemble/path"
      ARGV<<"--warn_as_err"
      ARGV<<"--on_server"
    end
  
end