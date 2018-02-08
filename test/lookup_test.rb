require "helper"

describe Toys::Lookup do
  let(:lookup) {
    Toys::Lookup.new(config_dir_name: ".toys",
                     config_file_name: ".toys.rb",
                     index_file_name: ".toys.rb")
  }
  let(:cases_dir) {
    File.join(__dir__, "lookup-cases")
  }

  describe "config path with one config file" do
    before do
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
    end

    it "finds a tool directly defined" do
      tool = lookup.lookup(["tool-1"])
      tool.short_desc.must_equal "tool-1 short description"
      tool.long_desc.must_equal "tool-1 long description"
    end

    it "finds a subtool directly defined" do
      tool = lookup.lookup(["collection-1", "tool-1-2"])
      tool.short_desc.must_equal "tool-1-2 short description"
      tool.long_desc.must_equal "tool-1-2 long description"
      tool.full_name.must_equal ["collection-1", "tool-1-2"]
    end

    it "finds a collection directly defined" do
      tool = lookup.lookup(["collection-1"])
      tool.short_desc.must_equal "collection-1 short description"
      tool.full_name.must_equal ["collection-1"]
    end

    it "finds the nearest collection directly defined if a query doesn't match" do
      tool = lookup.lookup(["collection-1", "tool-blah"])
      tool.short_desc.must_equal "collection-1 short description"
      tool.full_name.must_equal ["collection-1"]
    end

    it "finds the root if a query has no toplevel match" do
      tool = lookup.lookup(["tool-blah"])
      tool.full_name.must_equal []
      tool.simple_name.must_be_nil
    end
  end

  describe "ordinary path with one index file" do
    before do
      lookup.prepend_paths(File.join(cases_dir, "index-file-only"))
    end

    it "finds a tool directly defined" do
      tool = lookup.lookup(["tool-1"])
      tool.short_desc.must_equal "tool-1 short description"
      tool.long_desc.must_equal "tool-1 long description"
    end
  end

  describe "ordinary path with some hierarchical files" do
    before do
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
    end

    it "finds a tool directly defined" do
      tool = lookup.lookup(["tool-1"])
      tool.short_desc.must_equal "normal tool-1 short description"
      tool.long_desc.must_equal "normal tool-1 long description"
    end

    it "finds a subtool directly defined" do
      tool = lookup.lookup(["collection-1", "tool-1-3"])
      tool.short_desc.must_equal "normal tool-1-3 short description"
      tool.long_desc.must_equal "normal tool-1-3 long description"
      tool.full_name.must_equal ["collection-1", "tool-1-3"]
    end

    it "finds a collection directly defined" do
      tool = lookup.lookup(["collection-1"])
      tool.short_desc.must_be_nil
      tool.full_name.must_equal ["collection-1"]
    end

    it "finds the nearest collection directly defined if a query doesn't match" do
      tool = lookup.lookup(["collection-1", "tool-blah"])
      tool.short_desc.must_be_nil
      tool.full_name.must_equal ["collection-1"]
    end

    it "finds the root if a query has no toplevel match" do
      tool = lookup.lookup(["tool-blah"])
      tool.full_name.must_equal []
      tool.simple_name.must_be_nil
    end

    it "does not load unnecessary files" do
      lookup.lookup(["collection-1", "tool-1-3"])
      lookup.tool_defined?(["collection-1", "tool-1-3"]).must_equal true
      lookup.tool_defined?(["collection-1"]).must_equal true
      lookup.tool_defined?(["collection-1", "tool-1-1"]).must_equal false
      lookup.tool_defined?(["tool-1"]).must_equal false
      lookup.lookup(["tool-1"])
      lookup.tool_defined?(["tool-1"]).must_equal true
    end

    it "loads all descendants of a collection query" do
      lookup.lookup([])
      lookup.tool_defined?(["collection-1", "tool-1-3"]).must_equal true
      lookup.tool_defined?(["tool-1"]).must_equal true
    end
  end

  describe "paths with priorities" do
    it "finds a conflicting tool with priority given to a config file" do
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      tool = lookup.lookup(["tool-1"])
      tool.short_desc.must_equal "tool-1 short description"
      tool.long_desc.must_equal "tool-1 long description"
    end

    it "finds a conflicting tool with priority given to a normal file" do
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      tool = lookup.lookup(["tool-1"])
      tool.short_desc.must_equal "normal tool-1 short description"
      tool.long_desc.must_equal "normal tool-1 long description"
    end

    it "finds a conflicting subtool with priority given to a config file" do
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      tool = lookup.lookup(["collection-1", "tool-1-1"])
      tool.short_desc.must_equal "tool-1-1 short description"
      tool.long_desc.must_equal "tool-1-1 long description"
    end

    it "finds a conflicting subtool with priority given to a normal file" do
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      tool = lookup.lookup(["collection-1", "tool-1-1"])
      tool.short_desc.must_equal "normal tool-1-1 short description"
      tool.long_desc.must_equal "normal tool-1-1 long description"
    end

    it "finds a tool defined only in the lower priority path" do
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      tool = lookup.lookup(["tool-3"])
      tool.short_desc.must_equal "normal tool-3 short description"
      tool.long_desc.must_equal "normal tool-3 long description"
    end

    it "finds a subtool defined only in the lower priority path but with a conflicting parent" do
      lookup.prepend_paths(File.join(cases_dir, "normal-file-hierarchy"))
      lookup.prepend_config_paths(File.join(cases_dir, "index-file-only"))
      tool = lookup.lookup(["collection-1", "tool-1-3"])
      tool.short_desc.must_equal "normal tool-1-3 short description"
      tool.long_desc.must_equal "normal tool-1-3 long description"
    end
  end
end
