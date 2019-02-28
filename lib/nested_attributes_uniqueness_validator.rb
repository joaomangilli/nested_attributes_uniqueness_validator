class NestedAttributesUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless options[:allow_destroyed] == false
      value = value.reject(&:marked_for_destruction?)
    end

    scope = [options[:scope]].flatten

    same_object = value.detect do |object|
      value.select do |obj|
        scope.map do |scope_attribute|
          a = obj.try(scope_attribute)
          b = object.try(scope_attribute)

          if options[:allow_blank] == true
            (a == b)
          else
            (a.present? || b.present?) && (a == b)
          end
        end.all?
      end.count > 1
    end

    return unless same_object.present?

    same_object.errors.add(
      options.fetch(:attribute, scope.first),
      options.fetch(:message, :taken)
    )
    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
