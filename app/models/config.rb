class Config
  include ActiveModel::Model

  attr_accessor :ils_adapter
  attr_accessor :search_engine_adapter
  attr_accessor :scopes

  def ils_adapter
    @ils_adapter.first
  end

  def ils_adapter=(value)
    @ils_adapter = value.map do |_key, _value|
      IlsAdapter.new({id: _key, config: self}.merge(_value))
    end
  end

  def search_engine_adapter=(value)
    @search_engine_adapter = value.map do |_key, _value|
      SearchEngineAdapter.new({id: _key, config: self}.merge(_value))
    end
  end

  def scopes=(value)
    @scopes = value.map do |_key, _value|
      Scope.new({id: _key, config: self}.merge(_value))
    end
  end

  def find_adapter(adapter_id)
    [@ils_adapter, @search_engine_adapter].flatten(1).find do |_adapter|
      _adapter.id == adapter_id
    end
  end
  alias_method :find_ils_adapter,           :find_adapter
  alias_method :find_search_engine_adapter, :find_adapter

  def find_scope(scope_id)
    scopes.find{|scope| scope.id == scope_id.to_s}
  end

end
