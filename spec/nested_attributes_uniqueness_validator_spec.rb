class Parent
  include ActiveModel::Model

  attr_accessor :children

  validates(
    :children,
    nested_attributes_uniqueness: {
      attribute: :number,
      scope: %i[id number],
      message: 'Message'
    }
  )
end

class ParentWithoutAttribute
  include ActiveModel::Model

  attr_accessor :children

  validates(
    :children,
    nested_attributes_uniqueness: { scope: %i[id number] }
  )
end

class ParentWithoutScope
  include ActiveModel::Model

  attr_accessor :children

  validates :children, nested_attributes_uniqueness: { attribute: :number }
end

class Child
  include ActiveModel::Model

  attr_accessor :id, :number, :marked_for_destruction

  alias marked_for_destruction? marked_for_destruction
end

describe NestedAttributesUniquenessValidator do
  let(:message) { 'Message' }

  context 'when :scope is not present' do
    subject { ParentWithoutScope.new }

    it do
      expect { subject.valid? }.to(
        raise_exception(NestedAttributesUniquenessValidator::MissingScopeError)
      )
    end
  end

  context 'when :scope is present' do
    subject { ParentWithoutAttribute.new(children: children) }

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
        subject { Parent.new(children: children) }

        before { subject.valid? }

        it { expect(subject.errors[:children]).to include(message) }
        it { expect(child_one.errors[:number]).to include(message) }
      end
    end

    context 'and there are no duplicate childrens' do
      subject { Parent.new(children: children) }

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
      subject { Parent.new(children: children) }

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
