require 'test/unit'
require 'digest/md5'
require_relative '../lib/ones_devtool/ones_mdstream'
require_relative '../lib/ones_devtool/ones_mdscontainer'

class Ones_mdstreamTest < Test::Unit::TestCase
  @@mdsc="./test/ones_mdscontainer.res/test.epf"
  @@not_mdsc="./test/ones_mdscontainer.res/not_container"
  @@mdc_out = "./tmp/ones_mdsc.out"
  @@mdc_dir = "./tmp/ones_mdsc.dir"
  
  def test_container?
    assert_equal true,Ones_mdscontaiter.container?(@@mdsc)
    assert_equal false,Ones_mdscontaiter.container?(@@not_mdsc)
  end
  
  def test_disassemble_assemle
    Ones_mdscontaiter.disassemble(@@mdsc,@@mdc_dir)
    Ones_mdscontaiter.assemble(@@mdc_dir,@@mdc_out)
    assert_equal Digest::MD5.hexdigest(File.read(@@mdsc)),Digest::MD5.hexdigest(File.read(@@mdc_out))
    assert_equal true,true
  end
end
  