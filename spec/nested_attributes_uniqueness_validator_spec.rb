class Parent
  include ActiveModel::Model

  attr_accessor :children, :attribute, :scope, :message

  validates(
    :children,
    nested_attributes_uniqueness: {
      attribute: :number,
      scope: :scope,
      message: :message
    }
  )
end

class Child
  include ActiveModel::Model

  attr_accessor :id, :number, :marked_for_destruction

  alias marked_for_destruction? marked_for_destruction
end

describe NestedAttributesUniquenessValidator do
  subject do
    Parent.new(
      children: children,
      attribute: attribute,
      scope: scope,
      message: message
    )
  end

  let(:children) { [] }
  let(:attribute) { nil }
  let(:scope) { nil }
  let(:message) { nil }

  context 'when :scope is not present' do
    let(:scope) { nil }

    it do
      expect { subject.valid? }.to(
        raise_exception(NestedAttributesUniquenessValidator::MissingScopeError)
      )
    end
  end

  context 'when :scope is present' do
    let(:scope) { %i[id number] }

    context 'and there are duplicate children' do
      let(:children) { [child_one, child_two] }

      let(:child_one) do
        Child.new(id: 1, number: 123, marked_for_destruction: false)
      end

      let(:child_two) do
        Child.new(id: 1, number: 123, marked_for_destruction: false)
      end

      before { subject.valid? }

      it { is_expected.to be_invalid }
      it { expect(subject.errors[:children]).to include(:invalid) }
      it { expect(child_one.errors[:id]).to include(:taken) }

      context 'and an attribute and a message are defined' do
        let(:attribute) { :number }
        let(:message) { 'Validation message' }

        before { subject.valid? }

        it { expect(subject.errors[:children]).to include(message) }
        it { expect(child_one.errors[:number]).to include(message) }
      end
    end

    context 'and there are no duplicate childrens' do
      let(:children) { [child_one, child_two] }

      let(:child_one) do
        Child.new(id: 1, number: 123, marked_for_destruction: false)
      end

      let(:child_two) do
        Child.new(id: 1, number: 124, marked_for_destruction: false)
      end

      before { subject.valid? }

      it { is_expected.to be_valid }
    end

    context 'and there are deleted childrens' do
      let(:children) { [child_one, child_two] }

      let(:child_one) do
        Child.new(id: 1, number: 123, marked_for_destruction: true)
      end

      let(:child_two) do
        Child.new(id: 1, number: 124, marked_for_destruction: false)
      end

      before { subject.valid? }

      it { is_expected.to be_valid }
    end
  end
end
