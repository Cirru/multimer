
ns multimer.view.render

defn render (db state-id)
  let
    (state $ get-in db ([] :states state-id))

    {}
      :files $ ->> (:files db)
        map $ fn (entry)
          [] (key entry)
            ->
              ->> (val entry)
                into $ {}
              dissoc :tree
              dissoc :ops

        into $ {}

      :users $ map
        fn (entry)
          [] (key entry)
            into ({})
              val entry

        :users db

      :state $ into ({})
        , state
      :profile $ if
        some? $ :user-id state
        into ({})
          get-in db $ [] :users :user-id
        , nil
