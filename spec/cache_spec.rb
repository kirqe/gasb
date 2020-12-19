require 'spec_helper'

describe "Cache" do
  describe 'self.get(key)' do
    $redis.mapped_hmset('now:12345', { term: 'now:12345', value: 12345 } )
    
    it 'returns a hash' do
      item = Cache.get('now:12345')
      expect(item).to be_a(Hash)
    end

    it 'returns nil if key doesnt exist' do
      item = Cache.get('now:1')
      expect(item).to eq({})
    end
  end

  describe 'self.set(key, value = {})' do
    it 'saves an item to the cache' do
      new_hash = { term: 'now:12345', value: 12345 }
      expect(Cache.set('now:12345', new_hash)).to eq(true)
    end    
  end

  describe 'self.exists?(key)' do
    it 'returns true if item exists' do
      $redis.mapped_hmset('now:12345', { term: 'now:12345', value: 12345 } )  
      expect(Cache.exists?('now:12345')).to be true
    end

    it 'returns false if item doesnt exist' do
      expect(Cache.exists?('now:123')).to be false
    end
  end
end
