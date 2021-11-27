# your own setting

API_ID = api_id
API_HASH = 'api_hash'

TDLIB_PATH = '/usr/local/lib'

LogFile = "../log/evaluation_server.log"
LogLevel = :debug
LogAge = 7
LogSize = 10

SystemPort = 8100
SystemBindAddress = "0.0.0.0"
HTTPAccessControl = "*"


# in second
Dialogue_History_Cache_Time = 3
# Dialogue_History_Cache_Time = 600

# this is for development
# to use stored file instead of fetching from server
#Dialogue_History_Stab_File = "./stab.db"
Dialogue_History_Stab_File = nil

# iframe file
IFRAME_FILE = "data/form_iframe"

