---
layout:     post
title:      Switching between multiple Java JDK versions in Emacs
date:       2020-07-02 00:00:00
categories: [distributed systems, consensus algorithm]
tags:       [Clojure, Emacs, hacks, Java, JDK]

author:
  name:  Bruno Bonacci
  image: bb.png
---

Like many people who work with JVM languages, I do have many version of
Java JDK installed on my machine. There are few utilities which help
managing which version a given project should use and how to switch
quickly between versions. Some of the most popular are:

  - [Jabba](https://github.com/shyiko/jabba)
  - [jenv](https://www.jenv.be/)

Others prefer, a much simpler way to switch between JDKs like what is
described in [Managing Multiple JDKs on macOS](https://metaredux.com/posts/2018/11/05/managing-multiple-jdks-on-macos.html).

Similarly to the previous article, I have a small function in my
`~/.profile` which allows me to quickly switch between installed versions
from a terminal prompt.


``` bash
# Add this to your bash profile (~/.bash_rc, ~/.bash_profile, ~/.profile)
#
# Base directory where all the different versions are
# installed. This is the default directory for MacOS
#
export JDK_BASE=/Library/Java/JavaVirtualMachines

function switch-java() {


    jvms=( `\ls -1 $JDK_BASE` )
    pref='jdk-'

    if [ "$1" = "8" ] ; then
        pref='jdk1.'
    fi

    if [ "$1" != "" ] ; then
        SELECTION=$(\ls -1 $JDK_BASE | grep $pref$1)
    fi

    if [ "$SELECTION" = "" ] ; then
        echo "Switch to which JVM?"
        for i in ${!jvms[@]}; do
            printf "   %2d - %s\n" $i ${jvms[$i]}
        done

        while [[ $SELECTION -ge ${#jvms[@]} ]] || [[ $SELECTION -lt 0 ]] || [[ $SELECTION == '' ]] ; do
            read -p "Select a JVM: " SELECTION
        done

        SELECTION=${jvms[$SELECTION]}
    fi

    echo '-----------------------------------------------------------------'
    echo "Switching to Java: $SELECTION"
    echo "Full path: $JDK_BASE/$SELECTION/Contents/Home"
    echo ":java-cmd \"$JDK_BASE/$SELECTION/Contents/Home/bin/java\""
    echo '-----------------------------------------------------------------'
    export JAVA_HOME=$JDK_BASE/$SELECTION/Contents/Home
    export JAVA_CMD=$JAVA_HOME/bin/java
    export PATH=$JAVA_HOME/bin:$PATH
    java -version
    echo '-----------------------------------------------------------------'

}
```

With this script you can select among the installed versions with
`switch-java -L` or jump to the desired version like `switch-java 12`.

This short terminal cast shows a how to use it:

<script id="asciicast-344675" src="https://asciinema.org/a/344675.js" async></script>

<!-- [![asciicast](https://asciinema.org/a/344675.svg)](https://asciinema.org/a/344675) -->

Now this works extremely well for all the terminal uses, however,
most of my development is currently done in Clojure using
[Emacs + Cider](https://github.com/clojure-emacs/cider).

CIDER is a amazing IDE which truly harnesses the power of Clojure REPL
to enable a great experience with **REPL Driven Development** (thanks
[@bbatsov](https://github.com/bbatsov)).  However, there is no easy
way to switch java version from inside Emacs when firing the REPL.
*So in true Emacs spirit, I made my own solution*.

Add this to your `~/.emacs.d/init.el` and re-evaluate your buffer
(`M-x eval-buffer`).

``` emacs-lisp
;;
;; switch java
;;
(setq JAVA_BASE "/Library/Java/JavaVirtualMachines")

;;
;; This function returns the list of installed
;;
(defun switch-java--versions ()
  "Return the list of installed JDK."
  (seq-remove
   (lambda (a) (or (equal a ".") (equal a "..")))
   (directory-files JAVA_BASE)))


(defun switch-java--save-env ()
  "Store original PATH and JAVA_HOME."
  (when (not (boundp 'SW_JAVA_PATH))
    (setq SW_JAVA_PATH (getenv "PATH")))
  (when (not (boundp 'SW_JAVA_HOME))
    (setq SW_JAVA_HOME (getenv "JAVA_HOME"))))


(defun switch-java ()
  "List the installed JDKs and enable to switch the JDK in use."
  (interactive)
  ;; store original PATH and JAVA_HOME
  (switch-java--save-env)

  (let ((ver (completing-read
              "Which Java: "
              (seq-map-indexed
               (lambda (e i) (list e i)) (switch-java--versions))
              nil t "")))
    ;; switch java version
    (setenv "JAVA_HOME" (concat JAVA_BASE "/" ver "/Contents/Home"))
    (setenv "PATH" (concat (concat (getenv "JAVA_HOME") "/bin/java")
                           ":" SW_JAVA_PATH)))
  ;; show version
  (switch-java-which-version?))


(defun switch-java-default ()
  "Restore the default Java version."
  (interactive)
  ;; store original PATH and JAVA_HOME
  (switch-java--save-env)

  ;; switch java version
  (setenv "JAVA_HOME" SW_JAVA_HOME)
  (setenv "PATH" SW_JAVA_PATH)
  ;; show version
  (switch-java-which-version?))


(defun switch-java-which-version? ()
  "Display the current version selected Java version."
  (interactive)
  ;; displays current java version
  (message (concat "Java HOME: " (getenv "JAVA_HOME"))))
```

Here a short breakdown on the functions `switch-java-*`
  - `switch-java-which-version?` - Displays the current selected
    version in the message area.
  - `switch-java-default` - It restores the default Java version, the
    one in you system defaults.
  - `switch-java` - It lists the installed JDKs and prompt for a selection.

To switch version, just press `M-x switch-java` and select the desired
version. Here is a small screencast on how to use it:

![switch-java](/images/switch-java.gif)

***Disclaimer**: I'm not very proficient in Emacs Lisp and its
ecosystem, surely, there are better ways (or more elegant ways) to
achieve the same functionality.* If you have any suggestion on how to
improve I'll be happy to hear your feedback.
