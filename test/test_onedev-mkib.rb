require 'test/unit'
require_relative '../lib/ones_devtool/onedev_mkib'
require_relative '../lib/ones_devtool/ones_v8exe_wrapper'

require 'fileutils'

class OnedevMkibTest < Test::Unit::TestCase
  @@resdir = "./test/onedev_mkib.res/"
  @@bindir = "./bin"
  def test_common_param_all_param?()
    ARGV << "-F"
    ARGV << "file/path"
    ARGV<<"--rev"
    ARGV<<"2350"
    ARGV<<"--pattern_path"
    ARGV<<"pattern/path"
    
    command = :enterprise
    exp_common_param = {
      :F=>"file/path",
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil}
    }
    exp_options = {:rev=>"2350",:pattern_path=>"pattern/path"}
    options={}  
    common_params = Onedev_mkib.common_params(command,options)
    common_params.delete(:Out)
    assert_equal(exp_common_param,common_params)
    assert_equal(exp_options,options)
    
    common_params.delete(:F)
    assert_equal(false,Onedev_mkib.all_param?(command,common_params,options))
      
    common_params.update(:F=>"file/path")
    assert_equal(true,Onedev_mkib.all_param?(command,common_params,options))
    
    assert_equal(true,Onedev_mkib.all_param?(:fromf,common_params,options))
    assert_equal(true,Onedev_mkib.all_param?(:fromcf,common_params,options))
    assert_equal(true,Onedev_mkib.all_param?(:fromdt,common_params,options))
    options.delete(:pattern_path)
    assert_equal(false,Onedev_mkib.all_param?(:fromf,common_params,options))
    assert_equal(false,Onedev_mkib.all_param?(:fromcf,common_params,options))
    assert_equal(false,Onedev_mkib.all_param?(:fromdt,common_params,options))
    assert_equal(true,Onedev_mkib.all_param?(:mkib,common_params,options))
  end
  
  def test_mkib_f()
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "#{@@bindir}/onedev-mkib -F \"#{tmp_ib_path}\""
    
    assert_equal(0,$?.exitstatus)
    assert_equal(true,File.exists?(File.join(tmp_ib_path,"1Cv8.1CD")))

    FileUtils.rm_r(tmp_ib_path) if File.exists?(tmp_ib_path)
  end

  def test_mkib_fromcf()
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
    pattern_path = File.join(@@resdir,"test_cf_pattern")  
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "#{@@bindir}/onedev-mkib-fromcf -F #{tmp_ib_path} --pattern_path #{pattern_path}"
    
    assert_equal(0,$?.exitstatus) 
    assert_equal(true,File.exists?(File.join(tmp_ib_path,"1Cv8.1CD")))
      
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
  end

  def test_mkib_fromf()
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
    pattern_path = File.join(@@resdir,"test_cf_pattern.files")  
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "#{@@bindir}/onedev-mkib-fromf -F #{tmp_ib_path} --pattern_path #{pattern_path}"
    
    assert_equal(0,$?.exitstatus) 
    assert_equal(true,File.exists?(File.join(tmp_ib_path,"1Cv8.1CD")))
      
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
  end

  def test_mkib_fromf_rev()
    system "tar -xf #{File.join(@@resdir,'git.tar')} -C #{@@resdir}"
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
      
    pattern_path = File.join(@@resdir,"git","tmpib.cf.files")  
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "#{@@bindir}/onedev-mkib-fromf -F #{tmp_ib_path} --pattern_path #{pattern_path} --rev v1.0.0.2"
    
    assert_equal(0,$?.exitstatus) 
    assert_equal(true,File.exists?(File.join(tmp_ib_path,"1Cv8.1CD")))
      
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
    FileUtils.rm_rf(File.join(@@resdir,'git'))
  end

  
  def test_mkib_fromdt()
    tmp_ib_path = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib")
    pattern_path = File.join(@@resdir,"test_dt_pattern")  
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
    system "#{@@bindir}/onedev-mkib-fromdt -F #{tmp_ib_path} --pattern_path #{pattern_path}"
    
    assert_equal(0,$?.exitstatus) 
    assert_equal(true,File.exists?(File.join(tmp_ib_path,"1Cv8.1CD")))
      
    FileUtils.rm_rf(tmp_ib_path) if File.exists?(tmp_ib_path)
  end
    
    
end