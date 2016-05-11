
ns multimer.updater.vocabulary

defn add-word
  db op-data state-id op-id op-time
  update db :vocabulary $ fn (vocabulary)
    into (hash-set)
      conj vocabulary op-data

defn rm-word
  db op-data state-id op-id op-time
  update db :vocabulary $ fn (vocabulary)
    into (hash-set)
      filter
        fn (x)
          not= x op-data
        , vocabulary
