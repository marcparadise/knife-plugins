
# TODO play around with this in next iteration - pattern matching on
# hash keys. It'll need some rethinking, since dot notation won't work -
# conflicts with regex.

#class Hash
#  def has_rkey?(search)
#  end
#  # This one will complicate things as it means we'll potentially need to
#  # descend down multiple matching branches and capture results
#  def at_rkey(search)
#  end
#end
#
module Dbi
  class DbiShow < Chef::Knife
    banner "knife dbi show DATABAG ITEM KEY"
    option :json,
      :long => "--json",
      :short => "-j",
      :description => "format output as json",
      :boolean => true,
      :default => false

    option :usage,
      :long => "--usage",
      :short => "-u",
      :boolean => true,
      :proc => Proc.new{|x|
    puts <<EOS
Use to look up a specific value within the specified data bag item.
KEY is a dot-notated key to look up within the data bag item.

For example if your data bag looked like:
{
   "k1" => "a",
   "k2" => [ "a" => { "hello" => "world" },
             "b", "c"],
   "k3" => {
              "sk1" => "hello",
              "sk2" => "world"
           }
}

Then the results for a given key would be as follows:

knife dbi show k1 => "a"
knife dbi show k2.0 => { "hello" => "world" }
knife dbi.show k2.0.hello" => "world"
knife dbi show k2.1 => "b"
knife dbi show k3.sk1 => "hello"

In addition, you may request that the output be formatted as json
by specifying --json.

EOS
     }

    deps do
      require "chef/data_bag"
      require "chef/data_bag_item"
    end

    def run
      return if config[:usage]
      raise "databag name, item name, and key are required." if name_args.length != 3
      dbag, dbagitem, key = name_args

      # We'll fail here with an exception if the data bag and item don't exist. That's ok.
      raw = Chef::DataBagItem.load(dbag, dbagitem).raw_data

      # Key is expected to be a dot-separated, so we'll feed it into a lookup function
      # that descendds into the nested hash one level for each level in the key.
      results = value(raw, key.split("."), "")
      if config[:json]
        presenter = Chef::Knife::Core::GenericPresenter.new(ui, {:format => 'json'})
        puts presenter.format(results)
      else
        presenter = Chef::Knife::Core::GenericPresenter.new(ui, {:format => 'text'})
        formatted = presenter.format(results)
        if formatted.scan("\n").count > 1
          puts "#{ui.color(key, :green, :underline)}\n#{formatted}"
        else
          puts "#{ui.color(key, :green)} = #{formatted}"
        end
      end
    end

    def value(data, keys, done)
      raise "bad key into data bag item" if keys.length == 0
      key = keys.shift
      prettydone = ui.color("#{done.length > 0 ? done : "(root)"}", :red)
      prettykey = ui.color("'#{key}'", :red)

      # Some special treatment if data is an array - we want to give meaningful
      # response if index is not an integer or if it is out of range
      if data.instance_of?(Array)
        begin
          intkey = Integer(key)
        rescue
          raise "failed at #{prettydone}, this is an array but #{prettykey} is not a valid index"
        else
          if intkey < 0 or intkey >= data.length
            raise "failed at #{prettydone}, index #{prettykey} out of range (max #{data.length - 1})"
          end
          key = intkey
        end
      end

      newdata = data[key]
      raise "failed at #{prettydone}, could not find value at #{prettykey}" if newdata.nil?
      return newdata if keys.length == 0
      return value(newdata, keys, (done.length > 0 ? "#{done}.#{key}" : key))
    end

    def has_children?(data)
      data.instance_of?(Array) or data.instance_of?(Hash)
    end
  end
end
