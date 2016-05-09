
ns multimer.core $ :require
  [] multimer.schema :as schema
  [] multimer.util.file :refer $ [] read-from-dir
  [] differ.core :as differ
  [] cljs.reader :as reader
  [] multimer.view.render :refer $ [] render
  [] multimer.updater.core :refer $ [] updater

def shortid $ js/require |shortid

def WebSocketServer $ .-Server (js/require |ws)

defonce wss $ new WebSocketServer (js-obj |port 7100)

defonce sockets-ref $ atom ({})

defonce caches-ref $ atom ({})

defonce db-ref $ atom
  let
    (files $ read-from-dir | |../demo/)
    -- .log js/console files
    schema/Database. files ({})
      {}

defn handle-message (message)
  let
    (([] state-id op op-data) message)
      op-id $ .generate shortid
      op-time $ .valueOf (js/Date.)
      new-store $ updater @db-ref op op-data state-id op-id op-time

    println |message message
    reset! db-ref new-store

defn dispatch-changes ()
  println |changes @sockets-ref $ map :id (:states @db-ref)
  doseq
    [] state-id $ map
      fn (entry)
        :id $ val entry
      :states @db-ref

    let
      (ws $ get @sockets-ref state-id)
        store-cache $ get @caches-ref state-id
        latest-store $ render @db-ref state-id
      println ws state-id
      .send ws $ pr-str
        differ/diff
          or store-cache $ {}
          , latest-store

      swap! caches-ref assoc state-id latest-store

defn handle-ws (ws)
  let
    (id $ .generate shortid)
    swap! sockets-ref assoc id ws
    handle-message $ [] id :state/connect nil
    .on ws |message $ fn (message)
      let
        (([] op op-data) (reader/read-string message))

        handle-message $ [] id op op-data

    .on ws |close $ fn ()
      swap! sockets-ref dissoc id
      do
        .on ws |close identity
        handle-message $ [] id :state/disconnect nil
      .on ws |message identity

defn -main ()
  enable-console-print!
  .on wss |connection handle-ws
  println |database: $ pr-str @db-ref
  println "|app loaded"
  add-watch db-ref :change dispatch-changes

set! *main-cli-fn* -main

defn on-jsload ()
  println "|code updated."
  .on wss |connection handle-ws
  remove-watch db-ref :change
  add-watch db-ref :change dispatch-changes
