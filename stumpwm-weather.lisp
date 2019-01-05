;;;; stumpwm-weather.lisp

(in-package #:stumpwm-weather)
(enable-ia-syntax)

(defvar *units* nil)
(when (null *units*) (setf *units* "metric"))

;; (weather-format "%l %L %n %c %s %S %d %D %t %H %p %T %h %w %W")
(defvar *weather-format-string-alist*
  '((#\l weather-lon)
    (#\L weather-lat)
    (#\n weather-name)
    (#\c weather-country)
    (#\s weather-sunrise)
    (#\S weather-sunset)
    (#\d weather-desc-short)
    (#\D weather-desc-long)
    (#\t weather-temp)
    (#\H weather-humidity)
    (#\p weather-pressure)
    (#\T weather-temp-min)
    (#\h weather-temp-max)
    (#\w weather-wind-speed)
    (#\W weather-wind-deg)))

(defvar *format-str* nil)
(when (null *format-str*) (setf *format-str* "%H% %d %t°C"))

(defun weather-format (str)
  (stumpwm:format-expand *weather-format-string-alist* str))

(defvar *time-format-str* nil)
(when (null *time-format-str*)
  (setf *time-format-str* "%H:%M:%S"))

(defun weather-time-format (fnum)
  (cl-strftime:format-time
   nil
   *time-format-str*
   (+ (encode-universal-time 0 0 0 1 1 1970 0) fnum)))

(defvar *current-weather* nil)
(defvar *open-weather-map-api-key* nil)
(defvar *location* nil)
(defvar *current-weather-timer* nil)

(defvar *mode-line-formatter* nil)
(when (null *mode-line-formatter*)
  (setf *mode-line-formatter* #\E))

(defvar *update-timer* nil)
(when (null *update-timer*)
  (setf *update-timer* 300))

(defun rec-plist-ia-hash-table (pl)
  (let ((ht (plist-ia-hash-table
             (if (stringp (first pl))
                 pl
                 (first pl)))))
    (maphash (lambda (k v)
               (when (listp v)
                 (setf (gethash k ht)
                       (rec-plist-ia-hash-table v))))
             ht)
    ht))

(defun http-get-ia-hash-table (req)
  (let ((stream (drakma:http-request
                 req
                 :want-stream t
                 :decode-content t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (rec-plist-ia-hash-table (yason:parse stream :object-as :plist))))

(defun update-weather ()
  (http-get-ia-hash-table
   (format nil
           "http://api.openweathermap.org/data/2.5/weather?zip=~a&units=~a&APPID=~a"
           *location*
           *units*
           *open-weather-map-api-key*)))

(defun current-weather ()
  (setf *current-weather* (update-weather)))

(defun weather-lon ()
  (format nil "~a" #I*current-weather*.coord.lon))

(defun weather-lat ()
  (format nil "~a" #I*current-weather*.coord.lat))

(defun weather-name ()
  (format nil "~a" #I*current-weather*.name))

(defun weather-country ()
  (format nil "~a" #I*current-weather*.sys.country))

(defun weather-sunrise ()
  (format nil "~a"  (weather-time-format #I*current-weather*.sys.sunrise)))

(defun weather-sunset ()
  (format nil "~a"  (weather-time-format #I*current-weather*.sys.sunset)))

(defun weather-desc-short ()
  (format nil "~a" #I*current-weather*.weather.main))

(defun weather-desc-long ()
  (format nil "~a" #I*current-weather*.weather.description))

(defun weather-temp ()
  (format nil "~a" #I*current-weather*.main.temp))

(defun weather-humidity ()
  (format nil "~a" #I*current-weather*.main.humidity))

(defun weather-pressure ()
  (format nil "~a" #I*current-weather*.main.pressure))

(defun weather-temp-min ()
  (format nil "~a" #I*current-weather*.main.temp_min))

(defun weather-temp-max ()
  (format nil "~a" #I*current-weather*.main.temp_max))

(defun weather-wind-speed ()
  (format nil "~a" #I*current-weather*.wind.speed))

(defun weather-wind-deg ()
  (format nil "~a" #I*current-weather*.wind.deg))

(defun mode-line-str (&rest r)
  (declare (ignore r))
  (if (null *current-weather*)
      (format nil "weather Not ready!")
      (weather-format *format-str*)))

(defun timer-off ()
  (if (timer-p *current-weather-timer*)
      (cancel-timer *current-weather-timer*)))

(defun timer-on ()
  (setf *current-weather-timer*
        (run-with-timer *update-timer*
                        *update-timer*
                        'current-weather)))

(defun on ()
  (current-weather)
  (timer-off)
  (timer-on))

(defun off ()
  (timer-off)
  (setf *current-weather* nil))

(add-screen-mode-line-formatter *mode-line-formatter* 'mode-line-str)
