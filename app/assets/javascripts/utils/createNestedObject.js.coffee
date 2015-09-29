window.app       ?= {}
window.app.utils ?= {}

# based on http://stackoverflow.com/questions/5484673/javascript-how-to-dynamically-create-nested-objects-using-object-names-given-by
window.app.utils.createNestedObject ?= (base, names, value) =>
  # If a value is given, remove the last name and keep it for later:
  lastName = if arguments.length is 3 then names.pop() else false

  # If we are given a string like "foo.bar.moep" transform this into an array
  names = names.split('.') if typeof names is 'string'

  # Walk the hierarchy, creating new objects where needed.
  # If the lastName was removed, then the last object is not set yet:
  base = base[name] ?= {} for name in names

  # If a value was given, set it to the last name:
  base = base[lastName] = value if lastName

  return base
