require 'test/unit'
require 'digest/md5'
require 'ones_devtool/ones_mdstream'

class Ones_mdstreamTest < Test::Unit::TestCase
  @@mdsfile="./test/ones_mdstream.res/root.stream"
  @@not_mdsfile="./test/ones_mdstream.res/not_stream"
  @@tmpfile = "./tmp/ones_mdsfile.out"
  def testA_read_mdsfile
    assert_equal true,Ones_mdstream.read_mdsfile(@@mdsfile).length > 0
    assert_equal true,Ones_mdstream.read_mdsfile(@@not_mdsfile).length == 0
  end

  def testB_write_mdsfile
     assert_equal true,Ones_mdstream.write_mdsfile(@@tmpfile,Ones_mdstream.read_mdsfile(@@mdsfile)) > 0
    assert_equal Digest::MD5.hexdigest(File.read(@@mdsfile)),Digest::MD5.hexdigest(File.read(@@tmpfile))   
    assert_equal true,File.open(@@not_mdsfile,"r:bom|utf-8"){|f| Ones_mdstream.write_mdsfile(@@tmpfile,f.read)} == 0
    File.delete(@@tmpfile)
  end
  
  def testC_pretty_stream()
    shifts=[false,true]
    shifts.each{|shift|
      stream = Ones_mdstream.read_mdsfile(@@mdsfile)
      assert_equal true, stream.length > 0
      pretty_stream=Ones_mdstream.pretty_stream(stream,shift)
      assert_equal true, pretty_stream.length > 0
      unpretty_stream = Ones_mdstream.unpretty_stream(stream)
      assert_equal true, unpretty_stream.length > 0
      #Сравниваем потоки
      assert_equal Digest::MD5.hexdigest(stream),Digest::MD5.hexdigest(unpretty_stream)   
      #write on disk
      assert_equal true, Ones_mdstream.write_mdsfile(@@tmpfile,unpretty_stream) > 0
      #Compare files
      assert_equal Digest::MD5.hexdigest(File.read(@@mdsfile)),Digest::MD5.hexdigest(File.read(@@tmpfile))   
      File.delete(@@tmpfile)
    }
  end  
 end