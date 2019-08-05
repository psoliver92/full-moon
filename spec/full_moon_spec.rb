require 'full_moon'
require 'timecop'

describe FullMoon::NextFullMoon do
  it "IsFullMoon assert true" do
    expect(FullMoon::IsFullMoon.is_full_moon('2018-01-02')).to eql(true)
  end

  it "IsFullMoon assert true" do
    expect(FullMoon::IsFullMoon.is_full_moon('2018-01-01')).to eql(false)
  end

  it "NextFullMoon 2018-01-02" do
    Timecop.freeze(Time.parse('20171220 15:05:00')) do
      expect(FullMoon::NextFullMoon.next_full_moon).to eql(1514864066)
    end
  end

  it "NextFullMoon 2018-01-31" do
    Timecop.freeze(Time.parse('20180104 08:54:00')) do
      expect(FullMoon::NextFullMoon.next_full_moon).to eql(1517422824)
    end
  end

  it "NextFullMoon 2018-01-31" do
    expect(FullMoon::NextFullMoon.next_full_moon_from(Time.parse('20180104 08:54:00'))).to eql(1517422824)
  end
end
