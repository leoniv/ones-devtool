module Version
  INFO = {
    :major =>0,
    :minor =>5,
    :patch =>2
  }

  NAME = 'ones_devtool'
  VERSION = [ INFO[:major], INFO[:minor], INFO[:patch] ].join( '.' )
end