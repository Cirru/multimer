
ns multimer.updater.core $ :require
  [] multimer.updater.state :as state
  [] multimer.updater.user :as user

defn updater
  db op op-data state-id op-id op-time
  case op
    :state/connect $ state/connect db op-data state-id op-id op-time
    :state/disconnect $ state/disconnect db op-data state-id op-id op-time
    :user/join $ user/join db op-data state-id op-id op-time
    , db
