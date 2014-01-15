require "chef/search/query"

module Tagops
  class TagopsRemovebyrole < Chef::Knife
    banner 'knife tagops removebyrole ROLE TAG'
    option :usage,
      :long => "--usage",
      :short => "-u",
      :boolean => true,
      :proc => Proc.new{|x|
    puts <<EOS
Use to remove TAG from any nodes in ROLE that have it assigned.

For example:

knife tagops removeall my-role sometagname
EOS
    }
    deps do
    end

    def run
      return if config[:usage]
      raise "Usage: knife tagops removebyrole ROLE-NAME TAG-NAME" if name_args.length != 2
      role, tag = name_args

      @searcher ||= Chef::Search::Query.new
      nodes = @searcher.search(:node, "role:#{role} AND tags:#{tag}")[0]
      if nodes.length == 0
        puts ui.color("No nodes in role #{role} found with tag #{tag}", :yellow)
        return
      end

      nodes.each do |node|
        puts "Removing tag #{ui.color(tag, :green)} from node #{ui.color(node.name, :green)}"
        node.tags.delete tag
        node.save
      end
    end
  end
  class TagopsCreatebyrole < Chef::Knife
    banner 'knife tagops createbyrole TAG'

    option :usage,
      :long => "--usage",
      :short => "-u",
      :boolean => true,
      :proc => Proc.new{|x|
    puts <<EOS
Use to remove TAG from any nodes which have it assigned.

For example:

knife tagops createbyrole some-role-name some-tag-name
EOS
    }
    deps do

    end

    def run
      return if config[:usage]
      raise "Usage: knife tagops createbyrole ROLE-NAME TAG-NAME" if name_args.length != 2

      role, tag = name_args
      @searcher ||= Chef::Search::Query.new
      nodes = @searcher.search(:node, "role:#{role} AND NOT tags:#{tag}")[0]
      if nodes.length == 0
        puts ui.color("No nodes found for role #{role} and without tag #{tag}", :yellow)
        return
      end

      nodes.each do |node|
        puts "Tagging #{ui.color(node.name, :green)} with #{ui.color(tag, :green)}"
        node.tags << tag
        node.save
      end
    end
  end
end

