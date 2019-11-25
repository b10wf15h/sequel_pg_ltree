# SequelPgLtree

## notice
Sequel ORM postgresql ltree helper inspired by https://github.com/sjke/pg_ltree

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel_pg_ltree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel_pg_ltree

## Usage

```sql
 id | path
----+-------
  1 | A
  2 | A.B
  3 | A.C
  4 | A.C.D
  5 | A.C.E
  6 | A.C.F
  7 | A.B.G
```

```ruby
class Tree < Sequel::Model(:tree)
  plugin :pg_ltree, :column => :path
end

Tree.find(id: 2).root.path # => A
Tree.find(id: 2).parent.path # => A
Tree.where(id: 1).first.children.each do |c|
  c[:path]
end # => A.B  A.C

```

## TODO
tests should be added