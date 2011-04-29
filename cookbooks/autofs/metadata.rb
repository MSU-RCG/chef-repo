maintainer        "37signals"
maintainer_email  "sysadmins@37signals.com"
description       'Configures the automount daemon. Need a default attribute for the client
"autofs" : {
  "maps" : {
    "<main mount point>" : {
      "source" : "<auto.??>",
      "keys" : {
        "media": {
          "options" : "<filesystem options>",
          "server" : "<server>",
          "export" : "<volume>"
        }
      }
    }
  }
}'
version           "0.1"
