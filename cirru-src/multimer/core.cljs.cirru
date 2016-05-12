
ns multimer.core $ :require
  [] multimer.schema :as schema
  [] multimer.util.file :refer $ [] read-from-dir
  [] differ.core :as differ
  [] cljs.reader :as reader
  [] multimer.view.render :refer $ [] render
  [] multimer.updater.core :refer $ [] updater
  [] multimer.config :as config

def shortid $ js/require |shortid

def fs $ js/require |fs

def path $ js/require |path

def gaze $ js/require |gaze

def WebSocketServer $ .-Server (js/require |ws)

defonce wss $ new WebSocketServer (js-obj |port 7100)

defonce sockets-ref $ atom ({})

defonce caches-ref $ atom ({})

defonce db-ref $ atom
  let
    (files $ read-from-dir | config/base-dir)
    schema/Database. files ({})
      {}

defn handle-message (message)
  println |handle-message message
  let
    (([] state-id op op-data) message)
      op-id $ .generate shortid
      op-time $ .valueOf (js/Date.)
      new-store $ updater @db-ref op op-data state-id op-id op-time

    reset! db-ref new-store

defn dispatch-changes ()
  -- println |changes @sockets-ref $ map :id (:states @db-ref)
  doseq
    [] state-id $ map
      fn (entry)
        :id $ val entry
      :states @db-ref

    let
      (ws $ get @sockets-ref state-id)
        store-cache $ get @caches-ref state-id
        latest-store $ render @db-ref state-id
      .send ws $ pr-str
        differ/diff
          or store-cache $ {}
          , latest-store

      swap! caches-ref assoc state-id latest-store

defn handle-ws (ws)
  let
    (id $ .generate shortid)
      on-message $ fn (message)
        let
          (([] op op-data) (reader/read-string message))

          handle-message $ [] id op op-data

      on-close $ fn ()
        swap! sockets-ref dissoc id
        handle-message $ [] id :state/disconnect nil
        .removeAllListeners ws |close
        .removeAllListeners ws |message

    swap! sockets-ref assoc id ws
    handle-message $ [] id :state/connect nil
    .on ws |message on-message
    .on ws |close on-close

defn watch-disk ()
  gaze
    .join path config/base-dir |**/*
    fn (err watcher)
      println "|err in gaze:" err
      let
        (base-path $ .join path js/process.env.PWD config/base-dir)
        .on watcher |added $ fn (filepath)
          let
            (filename $ path.relative base-path filepath)
            println |added filename
            handle-message $ [] nil :file/record ([] filename config/base-dir)

        .on watcher |deleted $ fn (filepath)
          let
            (filename $ path.relative base-path filepath)
            println |deleted filename
            handle-message $ [] nil :file/remove filename

defn -main ()
  enable-console-print!
  .on wss |connection handle-ws
  println |database: $ pr-str @db-ref
  println "|app loaded."
  add-watch db-ref :change dispatch-changes
  watch-disk

set! *main-cli-fn* -main

defn on-jsload ()
  println "|code updated."
  .removeAllListeners wss |connection
  .on wss |connection handle-ws
  remove-watch db-ref :change
  add-watch db-ref :change dispatch-changes
  dispatch-changes
