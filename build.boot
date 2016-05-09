
(set-env!
 :asset-paths #{"assets"}
 :source-paths #{}
 :resource-paths #{"src"}

 :dev-dependencies '[]
 :dependencies '[[adzerk/boot-cljs          "1.7.170-3"   :scope "provided"]
                 [cirru/boot-cirru-sepal    "0.1.4"       :scope "provided"]
                 [org.clojure/clojure       "1.8.0"       :scope "test"]
                 [org.clojure/clojurescript "1.7.228"     :scope "test"]
                 [figwheel-sidecar          "0.5.2"       :scope "test"]
                 [com.cemerick/piggieback "0.2.1"   :scope "test"]
                 [org.clojure/tools.nrepl "0.2.10"  :scope "test"]
                 [org.clojure/core.async "0.2.374"  :scope "test"]
                 [ajchemist/boot-figwheel   "0.5.2-2"     :scope "test"]
                 [differ "0.3.1"]])

(require '[adzerk.boot-cljs :refer [cljs]]
         '[cirru-sepal.core :refer [cirru-sepal]]
         '[boot-figwheel])

(refer 'boot-figwheel :rename '{cljs-repl fw-cljs-repl}) ; avoid some symbols

(def +version+ "0.1.0")

(task-options!
  pom {:project     'mvc-works/boot-workflow
       :version     +version+
       :description "Workflow"
       :url         "https://github.com/mvc-works/boot-workflow"
       :scm         {:url "https://github.com/mvc-works/boot-workflow"}
       :license     {"MIT" "http://opensource.org/licenses/mit-license.php"}})

(set-env! :repositories #(conj % ["clojars" {:url "https://clojars.org/repo/"}]))

(deftask compile-cirru []
  (cirru-sepal :paths ["cirru-src"]))

(task-options!
 figwheel {:build-ids  ["dev"]
           :all-builds [{:id "dev"
                         :compiler {:main 'multimer.core
                                    :target :nodejs
                                    :source-map true
                                    :optimizations :none
                                    :output-to "app.js"
                                    :output-dir "server_out/"
                                    :verbose false}
                         :figwheel {:build-id  "dev"
                                    :on-jsload 'multimer.core/on-jsload
                                    :heads-up-display true
                                    :autoload true
                                    :target :nodejs
                                    :debug false}}]
           :figwheel-options {:repl true
                              :http-server-root "target"
                              :load-warninged-code false
                              :css-dirs ["target"]}})

(deftask dev []
  (set-env! :source-paths #(into % ["src"]))
  (comp
    (cirru-sepal :paths ["cirru-src"])
    (cirru-sepal :paths ["cirru-src"] :watch true)
    (repl)
    (figwheel)
    (target)))

(deftask build-simple []
  (comp
    (compile-cirru)
    (cljs :compiler-options {:target :nodejs})
    (target)))

; bug: after optimization, method exported from npm package breaks
(deftask build-advanced []
  (comp
    (compile-cirru)
    (cljs :compiler-options {:target :nodejs} :optimizations :advanced)
    (target)))

(deftask rsync []
  (fn [next-task]
    (fn [fileset]
      (sh "rsync" "-r" "target/" "tiye:repo/mvc-works/boot-workflow" "--exclude" "main.out" "--delete")
      (next-task fileset))))

(deftask send-tiye []
  (comp
    (build-advanced)
    (rsync)))

(deftask build []
  (comp
   (pom)
   (jar)
   (install)))

(deftask deploy []
  (comp
   (build)
   (push :repo "clojars" :gpg-sign (not (.endsWith +version+ "-SNAPSHOT")))))
