module DeepClone
  private def deep_clone(object = self)
    Marshal.load(Marshal.dump(object))
  end
end
