
ns multimer.updater.state $ :require
  [] multimer.schema :as schema

defn connect
  db op-data state-id op-id op-time
  assoc-in db ([] :states state-id)
    schema/State. state-id nil nil

defn disconnect
  db op-data state-id op-id op-time
  update db :states $ fn (states)
    dissoc states state-id

defn focus
  db op-data state-id op-id op-time
  assoc-in db
    [] :states state-id :focus
    , op-data

defn out
  db op-data state-id op-id op-time
  let
    (coord $ get-in db ([] :states state-id :focus 1))

    if
      and (some? coord)
        > (count coord)
          , 1

      assoc-in db
        [] :states state-id :focus 1
        into ([])
          butlast coord

      , db
