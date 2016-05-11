
ns multimer.updater.file $ :require
  [] multimer.schema :as schema

defn record-file
  db op-data state-id op-id op-time
  let
    (([] filename base-dir) op-data)

    assoc-in db ([] :files filename)
      schema/File. filename ([] $ [])
        , base-dir

defn remove-file
  db filename state-id op-id op-time
  update db :files $ fn (files)
    dissoc files filename
