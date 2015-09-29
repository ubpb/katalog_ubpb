# require lodash

deep_locate = (collection, comparator, result = []) ->
  if _.isArray(collection) || _.isObject(collection)
    # personally it don't like the original order of _.any's predicate
    # function (value, key, object) ... it should be (key, value, object)
    predicate = (_value, _index_or_key, _collection) ->
      comparator(_index_or_key, _value, _collection)

    if _.any(collection, predicate)
      result.push(collection)
    else
      _.forEach collection, (_value) =>
        deep_locate(_value, comparator, result)

  return result

((window.app ?= {}).utils ?= {}).deep_locate ?= deep_locate
