require 'spec_helper'
require 'group_by_match_type/union_find'

RSpec.describe GroupByMatchType::UnionFind do
  let(:union_group) { described_class.new }

  describe '#find_or_create' do
    it 'assigns the same group to identical items' do
      group1 = union_group.find_or_create(['a'])
      group2 = union_group.find_or_create(['a'])
      expect(group1).to eq(group2)
    end

    it 'assigns different groups to different items' do
      group1 = union_group.find_or_create(['a'])
      group2 = union_group.find_or_create(['b'])
      expect(group1).not_to eq(group2)
    end

    it 'merges two items into the same group' do
      union_group.find_or_create(['a'])
      union_group.find_or_create(['b'])
      union_group.find_or_create(['a', 'b'])

      group_a = union_group.find_or_create(['a'])
      group_b = union_group.find_or_create(['b'])

      expect(group_a).to eq(group_b)
    end

    it 'merges multiple items into the same group' do
      union_group.find_or_create(['a'])
      union_group.find_or_create(['b'])
      union_group.find_or_create(['c'])
      union_group.find_or_create(%w[a b c])

      group_a = union_group.find_or_create(['a'])
      group_b = union_group.find_or_create(['b'])
      group_c = union_group.find_or_create(['c'])

      expect(group_a).to eq(group_b)
      expect(group_b).to eq(group_c)
    end

    it 'returns nil for empty input' do
      expect(union_group.find_or_create([])).to be_nil
    end
  end
end
