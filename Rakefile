
desc "Run tests"
task :test do
  require 'rake/testtask'
  FileUtils.mkdir_p( File.join( File.dirname( __FILE__ ), 'tmp' ) )
  directory "testdata/examples/doc"
  Rake::TestTask.new do |t|
    t.libs << 'test'
#    t.verbose = false
  end
end

task :default => :test

desc "Build the gem"
task :build => [:test,:chmod,:clean] do
  lib = File.expand_path('../lib/', __FILE__)
  $:.unshift lib unless $:.include?(lib)
  require 'ones_devtool'
  puts "Build ... #{Version::NAME} #{Version::VERSION}"
  system "gem build #{Version::NAME}.gemspec"
end

desc "Set right mot for files"
task :chmod do
  puts "Chmod ..."
  begin
    Dir.glob(File.join( File.dirname( __FILE__ ), "bin",'**','*' )).each{|f|
      if File.file?(f)
         FileUtils.chmod 0755,f
      end
    }
    Dir.glob(File.join( File.dirname( __FILE__ ), "lib", "**", "*.rb" )).each{|f|
      if File.file?(f)
        FileUtils.chmod 0644,f
      end
    }
  rescue LoadError=>e
     fail( e.message )
  end
end

desc "Clean all temporary stuff"
task :clean do
  puts "Clean ..."
  begin
    require 'fileutils'
    FileUtils.remove_dir( File.join( File.dirname( __FILE__ ), 'tmp' ), true)
    FileUtils.rm_f Dir.glob(File.join( File.dirname( __FILE__ ), '*.gem'))
    FileUtils.rm_f Dir.glob(File.join( File.dirname( __FILE__ ), '*.tmp'))
    FileUtils.rm_f Dir.glob(File.join( File.dirname( __FILE__ ), '~'))
  rescue LoadError=>e
    fail( e.message )
  end
end


