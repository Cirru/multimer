
ns multimer.config

def port $ if (some? js/process.env.port)
  js/parseInt js/process.env.port
  , 7100

def base-dir js/process.env.base
