
ns multimer.updater.user $ :require
  [] multimer.schema :as schema

defn join
  db op-data state-id op-id op-time
  let
    (user-name $ first op-data)
      maybe-user $ ->> (:users db)
        vals
        filter $ fn (user)
          = (:name user)
            , user-name

        first

    if (some? maybe-user)
      assoc-in db
        [] :states state-id :user-id
        :id maybe-user
      let
        (new-user $ schema/User. op-id user-name nil)
        -> db
          assoc-in
            [] :states state-id :user-id
            , op-id
          assoc-in ([] :users op-id)
            , new-user
