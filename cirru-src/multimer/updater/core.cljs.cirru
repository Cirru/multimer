
ns multimer.updater.core $ :require
  [] multimer.updater.state :as state
  [] multimer.updater.user :as user
  [] multimer.updater.edit :as edit
  [] multimer.updater.effect :as effect
  [] multimer.updater.file :as file

defn updater
  db op op-data state-id op-id op-time
  case op
    :state/connect $ state/connect db op-data state-id op-id op-time
    :state/disconnect $ state/disconnect db op-data state-id op-id op-time
    :state/focus $ state/focus db op-data state-id op-id op-time
    :state/out $ state/out db op-data state-id op-id op-time
    :user/join $ user/join db op-data state-id op-id op-time
    :edit/update-token $ edit/update-token db op-data state-id op-id op-time
    :edit/append $ edit/append db op-data state-id op-id op-time
    :edit/prepend $ edit/prepend db op-data state-id op-id op-time
    :edit/fold $ edit/fold-expression db op-data state-id op-id op-time
    :edit/unfold $ edit/unfold-expression db op-data state-id op-id op-time
    :edit/append-line $ edit/append-line db op-data state-id op-id op-time
    :edit/prepend-line $ edit/prepend-line db op-data state-id op-id op-time
    :edit/insert $ edit/insert db op-data state-id op-id op-time
    :edit/remove $ edit/remove-node db op-data state-id op-id op-time
    :edit/new-expression $ edit/new-expression db op-data state-id op-id op-time
    :effect/save-file $ effect/save-file db op-data state-id op-id op-time
    :file/record $ file/record-file db op-data state-id op-id op-time
    :file/remove $ file/remove-file db op-data state-id op-id op-time
    , db
