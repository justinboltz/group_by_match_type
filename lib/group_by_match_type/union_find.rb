# frozen_string_literal: true

module GroupByMatchType
  class UnionFind
    def initialize
      @parent = {}
    end

    def find(item)
      @parent[item] = find(@parent[item]) if @parent[item] && @parent[item] != item
      @parent[item] ||= item
    end

    def union(source_item, target_item)
      source_root = find(source_item)
      target_root = find(target_item)
      @parent[source_root] = target_root unless source_root == target_root
    end

    def find_or_create(items)
      return nil if items.empty?

      items.map!(&:to_s)
      roots = items.map { |item| find(item) }
      main_root = roots.first
      roots[1..].each { |root| union(main_root, root) }
      main_root
    end
  end
end
