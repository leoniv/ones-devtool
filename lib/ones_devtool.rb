module Ones_devtool
 begin
    Dir.glob( File.join( File.dirname( __FILE__ ), "**", "*.rb" ) ).each { |l| require l }
  rescue LoadError => e
    $stderr.puts( e.message )
 end
end