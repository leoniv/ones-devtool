require 'test/unit'
require 'fileutils'
require_relative '../lib/ones_devtool/onedev_git'

class OndevGit < Test::Unit::TestCase
  @@resdir = "./test/onedev_git.res/"
  def test_get_rev()
    system "tar -xf #{File.join(@@resdir,'git.tar')} -C #{@@resdir}"
    repo = File.join(@@resdir,'git')
    sha1 = '932df5a5'
    exp_text1= '1' 
    sha2 = 'v.1.0.0'
    exp_text2= '2' 
    sha3 = '56bb2ed0'
    exp_text3= '3' 
    
    path_text1 = Onedev_git.get_rev(sha1,File.join(repo,"1.txt"))
    text1 = File.open(path_text1){|f| f.readline[0]}
    assert_equal(exp_text1,text1)   
   
    path_text2 = Onedev_git.get_rev(sha2,File.join(repo,"1.txt"))
    text2 = File.open(path_text2){|f| f.readline[0]}
    assert_equal(exp_text2,text2)   
    
    path_text3 = Onedev_git.get_rev(sha3,File.join(repo,"1.txt"))
    text3 = File.open(path_text3){|f| f.readline[0]}
    assert_equal(exp_text3,text3)   

    FileUtils.rm_rf(repo)
  end
  
  def test_get_gitindex
    system "tar -xf #{File.join(@@resdir,'git.tar')} -C #{@@resdir}"
    
    dip_path = FileUtils.mkdir_p(File.join(@@resdir,'git','1.tmp','2.tmp'))
    dip_path = FileUtils.touch(File.join(dip_path,'txt.tmp'))[0]
    exp_gitindex = File.join(@@resdir,'git')
    assert_equal(exp_gitindex,Onedev_git.get_gitindex(dip_path))
    FileUtils.rm_r(File.join(@@resdir,'git','1.tmp'))
    assert_equal(exp_gitindex,Onedev_git.get_gitindex(exp_gitindex))
    assert_raise(RuntimeError) do
      Onedev_git.get_gitindex('C:/')
    end    
    assert_raise(RuntimeError) do
      Onedev_git.get_gitindex('/')
    end    
  
    FileUtils.rm_rf(File.join(@@resdir,'git'))
  end
end
