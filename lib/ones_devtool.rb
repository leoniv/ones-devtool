module Ones_devtool
 raise "Не установлена переменная окружения $TMP" if not ENV.has_key?("TMP") or ENV["TMP"].length == 0
 begin
   Dir.glob( File.join( File.dirname( __FILE__ ), "ones_devtool", "*.rb" ) ).each { |l| require l }
  rescue LoadError => e
    $stderr.puts( e.message )
 end
end