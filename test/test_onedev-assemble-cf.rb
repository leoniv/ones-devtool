require 'test/unit'
require 'ones_devtool/ones_mdscontainer'

class Onedev_assembleTest < Test::Unit::TestCase
  @@mdsc="./test/ones_mdscontainer.res/test.epf"
  @@not_mdsc="./test/ones_mdscontainer.res/not_container"
  @@mdc_out = "./tmp/ones_mdsc.out#{Time.now.strftime '%m%S'}"
  @@mdc_dir = "./tmp/ones_mdsc.dir"
  
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
end
