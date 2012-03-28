require 'mongoid'

module Mongoid #:nodoc:

  # The Counter Cache will yada yada
  #
  #    class Person
  #      include Mongoid::Document
  #
  #      field :name
  #      field :feeling_count
  #      has_many :feelings
  #    end
  #
  #    class Feeling
  #      include Mongoid::Document
  #      include Mongoid::MagicCounterCache
  #
  #      field :name
  #      belongs_to    :person
  #      counter_cache :person
  #    end
  #
  # Alternative Syntax
  #
  #    class Person
  #      include Mongoid::Document
  #
  #      field :name
  #      field :all_my_feels
  #      has_many :feelings
  #    end
  #
  #    class Feeling
  #      include Mongoid::Document
  #      include Mongoid::MagicCounterCache
  #
  #      field :name
  #      belongs_to    :person
  #      counter_cache :person, :field => "all_my_feels"
  #    end
  module MagicCounterCache
    extend ActiveSupport::Concern

    module ClassMethods

      def counter_cache(*args, &block)
        options = args.extract_options!
        name    = options[:class] || args.first.to_s

        if options[:field]
          counter_name = "#{options[:field].to_s}"
        else
          counter_name = "#{model_name.downcase}_count"
        end
        after_create  do |doc|
          if doc.embedded?
            parent = doc._parent
            parent.inc(counter_name.to_sym, 1) if parent.respond_to? counter_name
          else
            relation = doc.send(name)
            if relation && relation.class.fields.keys.include?(counter_name)
              relation.inc(counter_name.to_sym,  1)
            end
          end
        end

        after_destroy do |doc|
          if doc.embedded?
            parent = doc._parent
            parent.inc(counter_name.to_sym, -1) if parent.respond_to? counter_name
          else
            relation = doc.send(name)
            if relation && relation.class.fields.keys.include?(counter_name)
              relation.inc(counter_name.to_sym, -1)
            end
          end
        end

      end

      alias :magic_counter_cache :counter_cache
    end

  end
end
