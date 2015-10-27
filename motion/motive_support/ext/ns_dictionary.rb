require 'active_support/core_ext/module/delegation'

class NSDictionary
  def to_hash
    Hash.new.tap do |h|
      h.replace self
    end
  end

  delegate :symbolize_keys, :deep_symbolize_keys,
           :stringify_keys, :deep_stringify_keys,
           :transform_keys, :deep_transform_keys,
           :with_indifferent_access, :nested_under_indifferent_access,
           :to => :to_hash
end
