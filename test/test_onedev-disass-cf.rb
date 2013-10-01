require 'test/unit'
require 'ones_devtool/ones_mdscontainer'

class Onedev_disassTest < Test::Unit::TestCase
  @@mdsc="./test/ones_mdscontainer.res/test.epf"
  @@not_mdsc="./test/ones_mdscontainer.res/not_container"
  @@mdc_out = "./tmp/ones_mdsc.out"
  @@mdc_dir = "./tmp/ones_mdsc.dir"
  
  def test_onedev_disass_cf
    Ones_mdscontaiter.disassemble(@@mdsc,@@mdc_dir)
    puts "Start \"./bin/onedev-dissass-cf #{@@mdsc} #{@@mdc_dir}\":"
    assert_equal true, system("./bin/onedev-dissass-cf #{@@mdsc} #{@@mdc_dir}")
 
    puts "Start \"./bin/onedev-dissass-cf -v #{@@mdsc}  #{@@mdc_dir}\":"
    assert_equal true, system("./bin/onedev-dissass-cf -v #{@@mdsc} #{@@mdc_dir}")
   end
end
