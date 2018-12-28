;;;; stumpwm-weather.asd

(asdf:defsystem #:stumpwm-weather
  :serial t
  :description "weather for StumpWM"
  :author "Voob of Doom <vod@njk.li>"
  :license "GPLv3"
  :version "0.0.1"
  :depends-on (#:stumpwm
               #:ia-hash-table
               #:drakma
               #:cl-strings
               #:cl-strftime
               #:flexi-streams
               #:yason)
  :components ((:file "package")
               (:file "stumpwm-weather")))
