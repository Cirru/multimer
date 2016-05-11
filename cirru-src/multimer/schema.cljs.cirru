
ns multimer.schema

defrecord User $ id name avatar

defrecord Focus $ file coord

defrecord State $ id user-id focus

defrecord Database $ files users states vocabulary

defrecord File $ name tree base
