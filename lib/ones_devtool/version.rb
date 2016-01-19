module Version
  INFO = {
    :major =>0,
    :minor =>6,
    :patch =>1
  }

  NAME = 'ones_devtool'
  VERSION = [ INFO[:major], INFO[:minor], INFO[:patch] ].join( '.' )
end
