# encoding: utf-8

require 'spec_helper'
require 'test_utils'


describe Hocon::CLI do
  ####################
  # Argument Parsing
  ####################
  context 'argument parsing' do
    it 'should find all the flags and arguments' do
      args = %w(-i foo -o bar set some.path some_value --json)
      expected_options = {
        in_file: 'foo',
        out_file: 'bar',
        subcommand: 'set',
        path: 'some.path',
        new_value: 'some_value',
        json: true
      }
      expect(Hocon::CLI.parse_args(args)).to eq(expected_options)
    end
  end

  context 'subcommands' do
    hocon_text =
'foo.bar {
  baz = 42
  array = [1, 2, 3]
  hash: {key: value}
}'

    context 'do_get()' do
      it 'should get simple values' do
        options = {path: 'foo.bar.baz'}
        expect(Hocon::CLI.do_get(options, hocon_text)).to eq('42')
      end

      it 'should work with arrays' do
        options = {path: 'foo.bar.array'}
        expected = "[\n    1,\n    2,\n    3\n]"
        expect(Hocon::CLI.do_get(options, hocon_text)).to eq(expected)
      end

      it 'should work with hashes' do
        options = {path: 'foo.bar.hash'}
        expected = "key=value\n"
        expect(Hocon::CLI.do_get(options, hocon_text)).to eq(expected)
      end

      it 'should output json if specified' do
        options = {path: 'foo.bar.hash', json: true}

        # Note that this is valid json, while the test above is not
        expected = "{\n    \"key\": \"value\"\n}\n"
        expect(Hocon::CLI.do_get(options, hocon_text)).to eq(expected)
      end
    end

    context 'do_set()' do
      it 'should overwrite values' do
        options = {path: 'foo.bar.baz', new_value: 'pi'}
        expected = hocon_text.sub(/42/, 'pi')
        expect(Hocon::CLI.do_set(options, hocon_text)).to eq(expected)
      end

      it 'should create new nested values' do
        options = {path: 'new.nested.path', new_value: 'hello'}
        expected = "new: {\n  nested: {\n    path: hello\n  }\n}"
        # No config is supplied, so it will need to add new nested hashes
        expect(Hocon::CLI.do_set(options, '')).to eq(expected)
      end
    end

    context 'do_unset()' do
      it 'should remove values' do
        options = {path: 'foo.bar.baz', new_value: 'pi'}
        expected = hocon_text.sub(/baz = 42/, '')
        expect(Hocon::CLI.do_unset(options, hocon_text)).to eq(expected)
      end
    end
  end
end
