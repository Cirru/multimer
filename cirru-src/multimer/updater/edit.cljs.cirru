
ns multimer.updater.edit

defn update-token
  db op-data state-id op-id op-time
  let
    (([] filename coord text) op-data)

    update-in db
      [] :files filename :tree
      fn (tree)
        assoc-in tree coord text

defn append
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)

    if
      > (count coord)
        , 1
      let
        (coord-before $ subvec coord 0 (dec $ count coord))

        -> db
          update-in
            [] :files filename :tree
            fn (tree)
              update-in tree coord-before $ fn (expression)
                into ([])
                  concat
                    subvec expression 0 $ inc (last coord)
                    [] |
                    subvec expression $ inc (last coord)

          assoc-in
            [] :states state-id :focus
            [] filename $ conj coord-before
              inc $ last coord

      , db

defn new-expression
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)

    if
      > (count coord)
        , 1
      let
        (coord-before $ subvec coord 0 (dec $ count coord))

        -> db
          update-in
            [] :files filename :tree
            fn (tree)
              update-in tree coord-before $ fn (expression)
                into ([])
                  concat
                    subvec expression 0 $ inc (last coord)
                    [] $ [] |
                    subvec expression $ inc (last coord)

          assoc-in
            [] :states state-id :focus
            [] filename $ conj coord-before
              inc $ last coord
              , 0

      , db

defn prepend
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)

    if
      > (count coord)
        , 1
      let
        (coord-before $ subvec coord 0 (dec $ count coord))

        -> db $ update-in
          [] :files filename :tree
          fn (tree)
            update-in tree coord-before $ fn (expression)
              into ([])
                concat
                  subvec expression 0 $ last coord
                  [] |
                  subvec expression $ last coord

      , db

defn insert
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)
      target $ get-in db
        concat
          [] :files filename :tree
          , coord

    -> db
      update-in
        [] :files filename :tree
        fn (tree)
          update-in tree coord $ fn (expression)
            if (vector? expression)
              conj expression |
              , expression

      assoc-in
        [] :states state-id :focus
        [] filename $ if (vector? target)
          conj coord $ count target
          , coord

defn remove-node
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)

    if
      > (count coord)
        , 0
      let
        (coord-before $ subvec coord 0 (dec $ count coord))

        -> db
          update-in
            [] :files filename :tree
            fn (tree)
              if
                = coord-before $ []
                into ([])
                  concat
                    subvec tree 0 $ last coord
                    subvec tree $ inc (last coord)

                update-in tree coord-before $ fn (expression)
                  if (vector? expression)
                    into ([])
                      concat
                        subvec expression 0 $ last coord
                        subvec expression $ inc (last coord)

                    , expression

          assoc-in
            [] :states state-id :focus
            [] filename $ if
              > (last coord)
                , 0
              conj coord-before $ dec (last coord)
              , coord-before

      , db

defn fold-expression
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)

    -> db
      update-in
        [] :files filename :tree
        fn (tree)
          update-in tree coord $ fn (expression)
            [] expression

      assoc-in
        [] :states state-id :focus
        [] filename $ conj coord 0

defn unfold-expression
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)
      coord-before $ subvec coord 0
        dec $ count coord
      target $ get-in db
        concat
          [] :files filename :tree
          , coord

    -> db
      update-in
        [] :files filename :tree
        fn (tree)
          update-in tree coord-before $ fn (expression)
            if
              vector? $ get expression (last coord)
              into ([])
                concat
                  subvec expression 0 $ last coord
                  get expression $ last coord
                  subvec expression $ inc (last coord)

              , expression

      assoc-in
        [] :states state-id :focus
        [] filename $ if (vector? target)
          , coord-before coord

defn append-line
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)
      line-pos $ first coord

    -> db
      update-in
        [] :files filename :tree
        fn (tree)
          into ([])
            concat
              subvec tree 0 $ inc line-pos
              [] $ []
              subvec tree $ inc line-pos

      assoc-in
        [] :states state-id :focus
        [] filename $ [] (inc line-pos)

defn prepend-line
  db op-data state-id op-id op-time
  let
    (([] filename coord) op-data)
      line-pos $ first coord

    -> db
      update-in
        [] :files filename :tree
        fn (tree)
          into ([])
            concat
              subvec tree 0 line-pos
              [] $ []
              subvec tree line-pos

      assoc-in
        [] :states state-id :focus
        [] filename $ [] line-pos
