require "chef/search/query"

module Tagops
  class TagopsRemoveall < Chef::Knife
    banner 'knife tagops removeall TAG'
    option :usage,
      :long => "--usage",
      :short => "-u",
      :boolean => true,
      :proc => Proc.new{|x|
    puts <<EOS
Use to assign TAG to any nodes that are assigned ROLE and not yet assigned TAG.

For example:

knife tagops removeall sometagname
EOS
    }
    deps do
    end

    def run
      return if config[:usage]
      raise "Usage: knife tagops removeall TAG-NAME" if name_args.length != 1
      tag = name_args[0]

      @searcher ||= Chef::Search::Query.new
      nodes = @searcher.search(:node, "tags:#{tag}")[0]
      if nodes.length == 0
        puts ui.color("No nodes found tag #{tag}", :yellow)
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

