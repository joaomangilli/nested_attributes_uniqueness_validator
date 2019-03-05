Gem::Specification.new do |s|
  s.name = 'nested_attributes_uniqueness_validator'
  s.version = '0.1.0'
  s.licenses = ['MIT']
  s.summary = 'Uniqueness validator for nested attributes.'
  s.description = <<-DESCRIPTION
    A uniqueness validator for nested attributes.

    This gem solves the problem described in https://github.com/rails/rails/issues/4568.
  DESCRIPTION
  s.authors = ['João Mangilli', 'Marcelo Alexandre']
  s.email = ['joaoluissilvamangilli@gmail.com', 'marcelobalexandre@gmail.com']
  s.files = ['lib/nested_attributes_uniqueness_validator.rb']
  s.homepage = 'https://github.com/joaomangilli/nested_attributes_uniqueness_validator'

  s.add_runtime_dependency 'activemodel', '>= 3.0'
  s.add_development_dependency 'rspec', '~> 3.8'
end
