require 'test/unit'
require 'digest/md5'
require 'ones_devtool/ones_mdstream'

class Ones_mdstreamTest < Test::Unit::TestCase
  @@resdir="./test/ones_mdstream.res/"
  @@tmpfile = "./tmp/ones_mdsfile.out"
  def testA_read_mdsfile
    Dir.glob("#{@@resdir}*.stream").each{|f|
      assert_equal true,Ones_mdstream.read_mdsfile(f).length > 0
    }  
    Dir.glob("#{@@resdir}*.no_stream").each{|f|
      assert_equal true ,Ones_mdstream.read_mdsfile(f).length == 0
    }  
  end

  def testB_write_mdsfile
    Dir.glob("#{@@resdir}*.stream").each{|f|
       File.open(f,"r:bom|utf-8"){|file| Ones_mdstream.write_mdsfile(@@tmpfile,file.read)}
       assert_equal Digest::MD5.hexdigest(File.read(f)),Digest::MD5.hexdigest(File.read(@@tmpfile))  
    }  
    Dir.glob("#{@@resdir}*.no_stream").each{|f|
      assert_equal true,File.open(f,"r:bom|utf-8"){|f| Ones_mdstream.write_mdsfile(@@tmpfile,f.read)} == 0
    }  
   File.delete(@@tmpfile)
  end
  
  def testC_pretty_stream(*arg)
    shifts=[false,true]
    shifts.each{|shift|
      Dir.glob("#{@@resdir}*.stream").each{|f|
  #      puts "pretty file #{f} sifts=#{shift}"
        stream = Ones_mdstream.read_mdsfile(f)
        pretty_stream=Ones_mdstream.pretty_stream(stream,shift)
        unpretty_stream = Ones_mdstream.unpretty_stream(stream,shift)
        #Сравниваем потоки
        assert_equal Digest::MD5.hexdigest(stream),Digest::MD5.hexdigest(unpretty_stream)   
        #write on disk
        assert_equal true, Ones_mdstream.write_mdsfile(@@tmpfile,unpretty_stream) > 0
        #Compare files
        assert_equal Digest::MD5.hexdigest(File.read(f)),Digest::MD5.hexdigest(File.read(@@tmpfile))   
        File.delete(@@tmpfile)
      }
    }
  end 
 end