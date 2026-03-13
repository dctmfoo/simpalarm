cask "simpalarm" do
  version "0.1.1"
  sha256 "4ccf55177d4c41074ead85767e3bba2a62baf783c2325bd774f949908b6eca23"

  url "https://github.com/dctmfoo/simpalarm/releases/download/v#{version}/SimpAlarm-#{version}.zip"
  name "SimpAlarm"
  desc "Menu bar alarm app for macOS"
  homepage "https://github.com/dctmfoo/simpalarm"

  depends_on macos: ">= :sonoma"

  app "SimpAlarm.app"
end
