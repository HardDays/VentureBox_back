require 'rails_helper'

RSpec.describe "shopify_orders:collect", type: :rake do
  it "rakes it out" do
    expect(subject).to be_a(Rake::Task)
    expect(subject.name).to eq("shopify_orders:collect")
    expect(subject).to eq(task)
  end

  context "cron time" do
    before do
      t = "2019-02-01T00:00:00".to_datetime
      Timecop.freeze(t)
    end

    it "updates values" do
      subject.execute
    end

    after do
      Timecop.return
    end
  end
end
