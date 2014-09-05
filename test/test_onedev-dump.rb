require 'test/unit'
require_relative '../lib/ones_devtool/onedev_dump'
require_relative '../lib/ones_devtool/ones_v8exe_wrapper'

require 'fileutils'

class OnedevDumpTest < Test::Unit::TestCase
  @@resdir = "./test/onedev_dump.res/"
  @@bindir = "./bin"
  def test_common_param_all_param?()
    ARGV << "-S"
    ARGV << "host:232/ibname"
    ARGV<<"--name"
    ARGV<<"user"
    ARGV<<"--password"
    ARGV<<"passw"
    ARGV<<"--uc"
    ARGV<<"uc code"
    
    ARGV<<"--dump_path"
    ARGV<<"dump/path"
    ARGV<<"--cf"
    ARGV<<"cf_name"
    ARGV<<"--dtf"
    ARGV<<"dt_name"
    ARGV<<"--force_clear"
    
    exp_common_param = {}
    exp_options = {:dump_path=>"dump/path",:cf=>"cf_name",:dtf=>"dt_name",:force_clear=>true}
    options={}  
    
    common_params = Onedev_dump.common_params(:dissass_cf_tof,options)
    
    assert_equal(exp_common_param,common_params)
    assert_equal(exp_options,options)

    ARGV << "-S"
    ARGV << "host:232/ibname"
    ARGV<<"--name"
    ARGV<<"user"
    ARGV<<"--password"
    ARGV<<"passw"
    ARGV<<"--uc"
    ARGV<<"uc code"
    
    ARGV<<"--dump_path"
    ARGV<<"dump/path"
    ARGV<<"--cf"
    ARGV<<"cf_name"
    ARGV<<"--dtf"
    ARGV<<"dt_name"

    ARGV<<"--force_clear"

    exp_common_param = {
      :S=>"host:232\\ibname",
      :N=>"user",
      :P=>"passw",
      :UC=>"uc code",
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}
    }
    
    
    common_params = Onedev_dump.common_params(:dump_infobase,options)
    common_params.delete(:Out)
    
    assert_equal(exp_common_param,common_params)
    assert_equal(exp_options,options)
    
    #all_param?(command,common_params,options) :S or :F
    assert_equal(true,Onedev_dump.all_param?(:dump_infobase,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:ibcf_tof,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:ibcf_tocf,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dbcf_tof,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dbcf_tocf,common_params,options))
    common_params.delete(:S)  
    assert_equal(false,Onedev_dump.all_param?(:dump_infobase,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:ibcf_tof,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:ibcf_tocf,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dbcf_tof,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dbcf_tocf,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dissass_cf_tof,common_params,options))
    
    #all_param?(command,common_params,options) :dump_path
    common_params.update(:F=>"path")
    options.delete(:dump_path)  

    assert_equal(false,Onedev_dump.all_param?(:dump_infobase,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:ibcf_tof,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:ibcf_tocf,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dbcf_tof,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dbcf_tocf,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dissass_cf_tof,common_params,options))

    #all_param?(command,common_params,options) :cf
    options.update(:dump_path=>"dump/path")  
    options.delete(:cf)      
    assert_equal(true,Onedev_dump.all_param?(:dump_infobase,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:ibcf_tof,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dbcf_tof,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:ibcf_tocf,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dbcf_tocf,common_params,options))
    assert_equal(false,Onedev_dump.all_param?(:dissass_cf_tof,common_params,options))
    
    #all_param?(command,common_params,options) :dtf
    options.update(:cf=>"cf_name")  
    options.delete(:dtf)      
    assert_equal(false,Onedev_dump.all_param?(:dump_infobase,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:ibcf_tof,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dbcf_tof,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:ibcf_tocf,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dbcf_tocf,common_params,options))
    assert_equal(true,Onedev_dump.all_param?(:dissass_cf_tof,common_params,options))
  end

  def test_dump_all
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
    dump_path = ENV["TMP"].gsub(/\\/){|s| s="/"}  
    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "tar -xf #{File.join(@@resdir,"tmpib.tar")} -C #{ENV["TMP"].gsub(/\\/){|s| s="/"}}"       
    
    #dump_infobase
    FileUtils.rm_r(File.join(dump_path,"dump_tmpib.dt")) if File.exists?(File.join(dump_path,"dump_tmpib.dt"))
    system "#{@@bindir}/onedev-dump-infobase -F #{tmp_ib_path} --dump_path #{dump_path} --dtf dump_tmpib.dt"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"dump_tmpib.dt")))
    FileUtils.rm_r(File.join(dump_path,"dump_tmpib.dt")) if File.exists?(File.join(dump_path,"dump_tmpib.dt"))
    
    #ibcf_tof
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf.files")) if File.exists?(File.join(dump_path,"tmpib.cf.files"))
    system "#{@@bindir}/onedev-dump-ibcf-tof -F #{tmp_ib_path} --dump_path #{File.join(dump_path,"tmpib.cf.files")}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
    #ibcf_tof --force_clear 
    system "#{@@bindir}/onedev-dump-ibcf-tof -F #{tmp_ib_path} --dump_path #{File.join(dump_path,"tmpib.cf.files")} --force_clear"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf.files")) if File.exists?(File.join(dump_path,"tmpib.cf.files"))
    
    #dbcf_tof
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf.files")) if File.exists?(File.join(dump_path,"tmpib.cf.files"))
    system "#{@@bindir}/onedev-dump-dbcf-tof -F #{tmp_ib_path} --dump_path #{File.join(dump_path,"tmpib.cf.files")}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
    #dbcf_tof --force_clear 
    system "#{@@bindir}/onedev-dump-dbcf-tof -F #{tmp_ib_path} --dump_path #{File.join(dump_path,"tmpib.cf.files")} --force_clear"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf.files")) if File.exists?(File.join(dump_path,"tmpib.cf.files"))
    
    #ifcf_tocf
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf")) if File.exists?(File.join(dump_path,"tmpib.cf"))
    system "#{@@bindir}/onedev-dump-ibcf-tocf -F #{tmp_ib_path} --dump_path #{dump_path} --cf tmpib.cf"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf")))
    #ifcf_tocf --force_clear 
    system "#{@@bindir}/onedev-dump-ibcf-tocf -F #{tmp_ib_path} --dump_path #{dump_path} --cf tmpib.cf --force_clear"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf")))
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf")) if File.exists?(File.join(dump_path,"tmpib.cf"))
    
    #dbcf_tocf
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf")) if File.exists?(File.join(dump_path,"tmpib.cf"))
    system "#{@@bindir}/onedev-dump-dbcf-tocf -F #{tmp_ib_path} --dump_path #{dump_path} --cf tmpib.cf"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf")))
    #dbcf_tocf --force_clear 
    system "#{@@bindir}/onedev-dump-dbcf-tocf -F #{tmp_ib_path} --dump_path #{dump_path} --cf tmpib.cf --force_clear"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf")))
    
    #dissass_cf_tof
    system "#{@@bindir}/onedev-dissass-cf-tof --dump_path #{File.join(dump_path,"tmpib.cf.files")} --cf #{File.join(dump_path,"tmpib.cf")}"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
    #dissass_cf_tof --force_clear 
    system "#{@@bindir}/onedev-dissass-cf-tof --dump_path #{File.join(dump_path,"tmpib.cf.files")} --cf #{File.join(dump_path,"tmpib.cf")} --force_clear"
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(dump_path,"tmpib.cf.files")))
   
        
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf")) if File.exists?(File.join(dump_path,"tmpib.cf"))
    FileUtils.rm_r(File.join(dump_path,"tmpib.cf.files")) if File.exists?(File.join(dump_path,"tmpib.cf.files"))
  
    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
  end
  
end  