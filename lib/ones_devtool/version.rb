module Version
  INFO = {
    :major =>0,
    :minor =>2,
    :patch =>3
  }

  NAME = 'ones_devtool'
  VERSION = [ INFO[:major], INFO[:minor], INFO[:patch] ].join( '.' )
end