require 'test/unit'
require_relative '../lib/ones_devtool/onedev_start'
require_relative '../lib/ones_devtool/ones_v8exe_wrapper'

require 'fileutils'

class OnedevStartTest < Test::Unit::TestCase
  def test_common_param()
    ARGV << "-S"
    ARGV << "host:235/ibname"
    ARGV<<"-N"
    ARGV<<"name"
    ARGV<<"-P"
    ARGV<<"pass"
    ARGV<<"--port"
    ARGV<<"2350"
    ARGV<<"--ord_app"
    ARGV<<"--mng_app"
    ARGV<<"--debug"
    ARGV<<"--debugger_url"
    ARGV<<"localhost"
    ARGV<<"--exec"
    ARGV<<"exec/path"
    ARGV<<"--cmd"
    ARGV<<"param1='param1 value';param2='param2 value'"
    ARGV<<"--uc"
    ARGV<<"lock str"
    
    command = :enterprise
    exp_common_param = {
      :S=>"host:235\\ibname",
      :N=>"name",
      :P=>"pass",
      :RunModeManagedApplication=>nil,
      :Debug=>nil,
      :DebuggerURL=>"localhost",
      :RunModeOrdinaryApplication=>nil,
      :DisableStartupDialogs=>nil,
      :DisableStartupMessages=>nil,
      :AllowExecuteScheduledJobs=>{:Off=>nil},
      :Execute=>"exec/path",
      :UC=>"lock str",
      :C=>"param1='param1 value';param2='param2 value'"  
    }
    common_params = Onedev_start.common_params(command)
    common_params.delete(:Out)
    assert_equal(exp_common_param,common_params)
  end
end
  