module GroupByMatchType
  class UnionFind
    def initialize
      @parent = {}
    end

    def find(x)
      @parent[x] = find(@parent[x]) if @parent[x] && @parent[x] != x
      @parent[x] ||= x
    end

    def union(x, y)
      root_x = find(x)
      root_y = find(y)
      @parent[root_x] = root_y unless root_x == root_y
    end

    def find_or_create(items)
      return nil if items.empty?
      items.map!(&:to_s)
      roots = items.map { |item| find(item) }
      main_root = roots.first
      roots[1..].each { |r| union(main_root, r) }
      main_root
    end
  end
end
