require 'active_support/core_ext/module/delegation'

class NSString
  def acts_like_string?
    true
  end

  def to_s
    String.new(self)
  end

  delegate :at, :blank?, :camelcase, :camelize, :classify, :constantize, :dasherize,
           :deconstantize, :demodulize, :exclude?, :first, :foreign_key, :from, :humanize,
           :indent, :last, :pluralize, :safe_constantize, :singularize,
           :squish, :strip_heredoc, :tableize, :titlecase, :titleize, :to,
           :truncate, :underscore,
           :to => :to_s
end
