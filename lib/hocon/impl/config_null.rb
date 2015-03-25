# encoding: utf-8

require 'hocon/impl'
require 'hocon/config_value_type'

class Hocon::Impl::ConfigNull < Hocon::Impl::AbstractConfigValue
  def value_type
    Hocon::ConfigValueType::NULL
  end

  def unwrapped
    nil
  end

  def transform_to_string
    "null"
  end

  def render_value_to_sb(sb, indent, at_root, options)
    sb << "null"
  end

  def newCopy(origin)
    ConfigNull.new(origin)
  end

end
