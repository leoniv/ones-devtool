module Version
  INFO = {
    :major =>0,
    :minor =>1,
    :patch =>5
  }

  NAME = 'ones_devtool'
  VERSION = [ INFO[:major], INFO[:minor], INFO[:patch] ].join( '.' )
end