;;;; package.lisp

(defpackage #:stumpwm-weather
  (:use #:cl #:stumpwm)
  (:export *mode-line-formatter*
           *update-timer*
           *open-weather-map-api-key*
           *location*
           *format-str*
           *time-format-str*
           *units*
           on
           off)
  (:import-from :ia-hash-table :plist-ia-hash-table :enable-ia-syntax))
