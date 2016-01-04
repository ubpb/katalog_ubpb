* When navigating forward/backward between searches#show and watch_lists#show
  using browser back/forward, records added to the watch list are not shown in
  watch_lists#show. This is because the watch lists "record list" is no component
  and does not update. Removing of entries is a jquery hack.
