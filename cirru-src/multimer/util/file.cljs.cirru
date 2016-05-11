
ns multimer.util.file $ :require
  [] multimer.schema :as schema
  [] cljs.reader :as reader

def fs $ js/require |fs

def path $ js/require |path

defn read-from-file (relative-name base-dir)
  -- println |read-from-file relative-name
  let
    (filename $ .join path base-dir relative-name)
      stat $ .statSync fs filename
      content $ .readFileSync fs filename |utf8
      tree $ if
        = (.trim content)
          , |
        []
        reader/read-string content

    schema/File. relative-name tree base-dir

defn read-from-dir (relative-name base-dir)
  -- .log js/console |read-from-dir relative-name
  let
    (dirname $ .join path base-dir relative-name)
      dir-list $ js->clj (.readdirSync fs dirname)
      children $ ->> dir-list
        map $ fn (filename)
          let
            (child-name $ .join path relative-name filename)
              real-child $ .join path dirname filename
              child-stat $ .statSync fs real-child
            -- println child-stat
            if (.isDirectory child-stat)
              read-from-dir child-name base-dir
              {} child-name $ read-from-file child-name base-dir

        apply merge

    , children
