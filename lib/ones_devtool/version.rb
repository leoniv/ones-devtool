module Version
  INFO = {
    :major =>0,
    :minor =>1,
    :patch =>4
  }

  NAME = 'ones_devtool'
  VERSION = [ INFO[:major], INFO[:minor], INFO[:patch] ].join( '.' )
end