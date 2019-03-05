class NestedAttributesUniquenessValidator < ActiveModel::EachValidator
  class MissingScopeError < StandardError; end

  def validate_each(record, attribute, value)
    parsed_options = parse_options(record)
    scope = [parsed_options[:scope]].flatten.compact

    raise MissingScopeError if scope.empty?

    unless parsed_options[:allow_destroyed] == true
      value = value.reject(&:marked_for_destruction?)
    end

    same_object = value.detect do |object|
      value.select do |obj|
        scope.map do |scope_attribute|
          a = obj.send(scope_attribute)
          b = object.send(scope_attribute)

          if parsed_options[:allow_blank] == true
            (a == b)
          else
            (a.present? || b.present?) && (a == b)
          end
        end.all?
      end.count > 1
    end

    return unless same_object.present?

    same_object.errors.add(
      parsed_options[:attribute].presence || scope.first,
      parsed_options[:message].presence || :taken
    )
    record.errors.add(attribute, parsed_options[:message].presence || :invalid)
  end

  private

  def parse_options(record)
    options.map.inject({}) do |hash, (key, value)|
      hash.merge(key => parse_option(value, record))
    end
  end

  def parse_option(param, record)
    case param
    when Symbol
      record.respond_to?(param) ? record.send(param) : param
    when Proc
      param.call(record)
    else
      param
    end
  end
end
