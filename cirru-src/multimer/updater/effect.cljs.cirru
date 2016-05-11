
ns multimer.updater.effect

def fs $ js/require |fs

def path $ js/require |path

defn save-file
  db op-data state-id op-id op-time
  let
    (file $ get-in db ([] :files op-data))
      base-dir $ :base file
      tree $ :tree file

    println "|Effect: saving file" base-dir op-data
    .writeFileSync fs
      .join path base-dir op-data
      pr-str tree

  , db
