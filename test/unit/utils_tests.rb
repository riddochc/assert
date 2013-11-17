require 'assert'
require 'assert/utils'

require 'tempfile'

module Assert::Utils

  class UnitTests < Assert::Context
    desc "Assert::Utils"
    subject{ Assert::Utils }
    setup do
      @objs = [ 1, 'hi there', Hash.new, [:a, :b]]
    end

    should have_imeths :show, :show_for_diff
    should have_imeths :tempfile
    should have_imeths :stdlib_pp_proc, :default_use_diff_proc, :syscmd_diff_proc

  end

  class ShowTests < UnitTests
    desc "`show`"
    setup do
      @orig_pp_objs = Assert.config.pp_objects
      @orig_pp_proc = Assert.config.pp_proc
      @new_pp_proc  = Proc.new{ |input| 'herp derp' }
    end
    teardown do
      Assert.config.pp_proc(@orig_pp_proc)
      Assert.config.pp_objects(@orig_pp_objs)
    end

    should "use `inspect` to show objs when `pp_objects` setting is false" do
      Assert.config.pp_objects(false)

      @objs.each do |obj|
        assert_equal obj.inspect, subject.show(obj)
      end
    end

    should "use `pp_proc` to show objs when `pp_objects` setting is true" do
      Assert.config.pp_objects(true)
      Assert.config.pp_proc(@new_pp_proc)

      @objs.each do |obj|
        assert_equal @new_pp_proc.call(obj), subject.show(obj)
      end
    end

  end

  class ShowForDiffTests < UnitTests
    desc "`show_for_diff`"
    setup do
      @w_newlines = { :string => "herp derp, derp herp\nherpderpedia" }
      @w_obj_id = Struct.new(:a, :b).new('aye', 'bee')
    end

    should "call show, escaping newlines" do
      exp_out = "{:string=>\"herp derp, derp herp\nherpderpedia\"}"
      assert_equal exp_out, subject.show_for_diff(@w_newlines)
    end

    should "make any obj ids generic" do
      exp_out = "#<struct #<Class:0xXXXXXX> a=\"aye\", b=\"bee\">"
      assert_equal exp_out, subject.show_for_diff(@w_obj_id)
    end

  end

  class TempfileTests < UnitTests
    desc "`tempfile`"

    should "require tempfile, open a tempfile, write the given content, and yield it" do
      subject.tempfile('a-name', 'some-content') do |tmpfile|
        assert_equal false, (require 'tempfile')
        assert tmpfile
        assert_kind_of Tempfile, tmpfile

        tmpfile.pos = 0
        assert_equal "some-content\n", tmpfile.read
      end
    end

  end

  class StdlibPpProcTests < UnitTests
    desc "`stdlib_pp_proc`"

    should "build a pp proc that uses stdlib `PP.pp` to pretty print objects" do
      exp_obj_pps = @objs.map{ |o| "\n#{PP.pp(o, '', 79).strip}\n" }
      act_obj_pps = @objs.map{ |o| subject.stdlib_pp_proc.call(o) }
      assert_equal exp_obj_pps, act_obj_pps

      cust_width = 1
      exp_obj_pps = @objs.map{ |o| "\n#{PP.pp(o, '', cust_width).strip}\n" }
      act_obj_pps = @objs.map{ |o| subject.stdlib_pp_proc(cust_width).call(o) }
      assert_equal exp_obj_pps, act_obj_pps
    end

  end

  class DefaultUseDiffProcTests < UnitTests
    desc "`default_use_diff_proc`"
    setup do
      @longer = "i am a really long string output; use diff when working with me"
      @newlines = "i have\n newlines"
    end

    should "be true if either output has newlines or is bigger than 29 chars" do
      proc = subject.default_use_diff_proc

      assert_not proc.call('', '')
      assert proc.call(@longer, '')
      assert proc.call(@newlines, '')
      assert proc.call('', @longer)
      assert proc.call('', @newlines)
      assert proc.call(@longer, @newlines)
    end

  end

  class SyscmdDiffProc < UnitTests
    desc "`syscmd_diff_proc`"
    setup do
      @diff_a_file = File.join(ROOT_PATH, 'test/support/diff_a.txt')
      @diff_b_file = File.join(ROOT_PATH, 'test/support/diff_b.txt')

      @diff_a = File.read(@diff_a_file)
      @diff_b = File.read(@diff_b_file)
    end

    should "use the diff syscmd to output the diff between the exp/act show output" do
      exp_diff_out = `diff --unified=-1 #{@diff_a_file} #{@diff_b_file}`.tap do |out|
        out.sub!(/^\-\-\- .+/, "--- expected")
        out.sub!(/^\+\+\+ .+/, "+++ actual")
      end

      assert_equal exp_diff_out, subject.syscmd_diff_proc.call(@diff_a, @diff_b)
    end

    should "allow you to specify a custom syscmd" do
      cust_syscmd = 'diff'
      exp_diff_out = `#{cust_syscmd} #{@diff_a_file} #{@diff_b_file}`.tap do |out|
        out.sub!(/^\-\-\- .+/, "--- expected")
        out.sub!(/^\+\+\+ .+/, "+++ actual")
      end

      assert_equal exp_diff_out, subject.syscmd_diff_proc(cust_syscmd).call(@diff_a, @diff_b)
    end

  end

end
