require 'test/unit'
require 'digest/md5'
require 'ones_devtool/ones_mdscontainer'

class Onedev_assembleTest < Test::Unit::TestCase
  @@mdsc="./test/ones_mdscontainer.res/test.epf"
  @@not_mdsc="./test/ones_mdscontainer.res/not_container"
  @@mdc_out = "./tmp/ones_mdsc.out#{Time.now.strftime '%m%S%L'}"
  @@mdc_dir = "./tmp/ones_mdsc.dir"
  @@resdir = "./test/onedev_assemble_cf.res/"
  
  def test_onedev_assemble_cf
    Ones_mdscontaiter.disassemble(@@mdsc,@@mdc_dir)
    puts "Start \"./bin/onedev-assemble-cf #{@@mdc_dir} #{@@mdc_out}\":"
    assert_equal true,system("./bin/onedev-assemble-cf #{@@mdc_dir} #{@@mdc_out}")
    puts "Start \"./bin/onedev-assemble-cf #{@@mdc_dir} -v #{@@mdc_out}\":"
    assert_equal false,system("./bin/onedev-assemble-cf -v #{@@mdc_dir} #{@@mdc_out}")
    FileUtils.rm_f(@@mdc_out)
    puts "Start \"./bin/onedev-assemble-cf #{@@mdc_dir} -v #{@@mdc_out}\":"
    assert_equal true,system("./bin/onedev-assemble-cf -v #{@@mdc_dir} #{@@mdc_out}")
  end
  def test_onedev_assemble_cf_rev
    #Пути
    tmp_git_repo = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib.gitrepo")
    cf_src = File.join(tmp_git_repo,"git","tmpib.cf.src")
    out_cf = File.join(ENV["TMP"].gsub(/\\/){|s| s="/"},"tmpib_cf_")
    exp_cf = File.join(@@resdir,"tmpib_cf_")
    #Создали временный git
    FileUtils.rm_r(tmp_git_repo) if File.exists?(tmp_git_repo)
    FileUtils.mkdir(tmp_git_repo)
    system "tar -xf #{File.join(@@resdir,"git.tar")} -C #{tmp_git_repo}"
    revs=%w"v1.0 v1.2 v1.4"
    revs.each do |rev|
      FileUtils.rm_r("#{out_cf}#{rev}") if File.exists?("#{out_cf}#{rev}")
      system "./bin/onedev-assemble-cf --rev #{rev} #{cf_src} #{out_cf}#{rev}"
      assert_equal(0,$?.exitstatus)
      #ассертация может проваливатся т.к. необходимо контролирвать сборку в ручную
      assert_equal(Digest::MD5.hexdigest(File.read("#{exp_cf}#{rev}")),Digest::MD5.hexdigest(File.read("#{out_cf}#{rev}")))
    end
    #Очистили
    FileUtils.rm_r(tmp_git_repo) if File.exists?(tmp_git_repo)
  end
end
