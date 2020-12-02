module Cache
  def self.get(key)
    h = Hash.new
    $redis.hgetall(key).each do |k, v|
      h[k.to_sym] = v
    end
    h
  end
  
  def self.set(key, value = {})
    $redis.mapped_hmset(key, value)
    true
  end

  def self.delete(key)
    $redis.del(key)
    true
  end

  def self.all(args={})
    if args[:id]
      $redis.keys("*:#{args[:id]}")  
    else
      $redis.keys("*")
    end
  end

  def self.exists?(key)
    $redis.exists?(key)
  end
end