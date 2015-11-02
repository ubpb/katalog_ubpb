class CacheEntry < ActiveRecord::Base

  # Validations
  validates_presence_of :key

  #
  # class methods
  #
  def self.key_factory(*args)
    Digest::SHA256.hexdigest(args.to_s)
  end

  # do not try to overwrite find_by_key because this will interfere rails db caching
  def self.read(key)
    find_by(key: key_factory(key))
  end

  def self.invalidate(key)
    where(key: key_factory(key)).destroy_all
  end

  #
  # instance methods
  #
  def expired?(duration)
    !(DateTime.now-duration..DateTime.now).cover?(updated_at)
  end
  
  def key=(value)
    super(self.class.key_factory(value))
  end
  
  def value
    deserialize(super)
  end

  def value=(object)
    super(serialize(object))
  end

  private

  def deserialize(serialized_object)
    if serialized_object.is_a?(String)
      Ox.parse_obj(serialized_object)
    else
      serialized_object
    end
  end

  def serialize(object)
    Ox.dump(object, indent: -1)
  end

end
