(defsystem "mud"
  :version "0.0.1"
  :description "A MUD server written in Common Lisp, inspired by DGD and LMUD"
  :author "Sophia"
  :license "MIT"
  :depends-on ("usocket"
               "bordeaux-threads"
               "str")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "constants" :depends-on ("package"))
                 (:file "utils" :depends-on ("package" "constants"))
                 (:file "object" :depends-on ("package" "constants" "utils"))
                 (:file "room" :depends-on ("object"))
                 (:file "world" :depends-on ("package" "constants" "object"))
                 (:file "character" :depends-on ("package" "constants" "object" "world"))
                 (:file "command-handler" :depends-on ("package" "constants" "character" "world"))
                 (:file "network" :depends-on ("package" "constants" "character" "command-handler"))))))
