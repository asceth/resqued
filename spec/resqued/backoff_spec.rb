require 'spec_helper'

require 'resqued/backoff'

describe Resqued::Backoff do
  let(:backoff) { described_class.new(:min => 1.0, :max => 64.0) }

  it 'can start on the first try' do
    expect(backoff.ok?).to be_true
  end

  it 'has no waiting at first' do
    expect(backoff.how_long?).to be_nil
  end

  context 'after expected exits' do
    before { 3.times { backoff.started } }
    it { expect(backoff.ok?).to be_true }
    it { expect(backoff.how_long?).to be_nil }
  end

  context 'after one quick exit' do
    before { 1.times { backoff.started ; backoff.died } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(1.0) }
  end

  context 'after two quick starts' do
    before { 2.times { backoff.started ; backoff.died } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(2.0) }
  end

  context 'after five quick starts' do
    before { 6.times { backoff.started ; backoff.died } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(32.0) }
  end

  context 'after five quick starts, old API' do
    before { 6.times { backoff.started ; backoff.finished } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(32.0) }
  end

  context 'after six quick starts' do
    before { 7.times { backoff.started ; backoff.died } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(64.0) }
  end

  context 'does not wait longer than 64s' do
    before { 8.times { backoff.started ; backoff.died } }
    it { expect(backoff.ok?).to be_false }
    it { expect(backoff.how_long?).to be_close_to(64.0) }
    it 'and resets after an expected exit' do
      backoff.started
      backoff.started
      expect(backoff.ok?).to be_true
    end
  end

  def be_close_to(x)
    be_within(0.005).of(x)
  end
end
