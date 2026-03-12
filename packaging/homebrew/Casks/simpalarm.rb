cask "simpalarm" do
  version "0.1.0"
  sha256 "73f97948a639a13c664096415dd3429c8068b7355424ae85302f02b5af5dec09"

  url "https://github.com/REPLACE_ME/simpalarm/releases/download/v#{version}/SimpAlarm-#{version}.zip"
  name "SimpAlarm"
  desc "Menu bar alarm app for macOS"
  homepage "https://github.com/REPLACE_ME/simpalarm"

  depends_on macos: ">= :sonoma"

  app "SimpAlarm.app"
end
