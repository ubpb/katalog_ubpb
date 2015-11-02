module CachingService
  extend ActiveSupport::Concern

  included do
    attr_accessor :from_cache # true/false
    attr_accessor :max_cache_age
  end

  def cache(key:, use_cached_result: from_cache?, &block)
    cache_entry = CacheEntry.read(key)

    if cache_entry.blank? || !use_cached_result || (max_cache_age && cache_entry.try!(:expired?, max_cache_age))
      cache_entry = update_cache(key: key, &block)
    end

    cache_entry.value
  end

  private

  def update_cache(key:, &block)
    block_result = yield
    CacheEntry.invalidate(key)
    CacheEntry.create!(key: key, value: block_result)
  end

  def from_cache?
    from_cache == true
  end
end
