cask "kaset" do
  version "0.1.1"
  sha256 "10ac2876c38c24a843b78da3afd3c1887e745318fb390aa941039eb3e9a70fac"

  url "https://github.com/sozercan/kaset/releases/download/v0.1.1/kaset-v0.1.1.dmg"
  name "Kaset"
  desc "Native macOS YouTube Music client"
  homepage "https://github.com/sozercan/kaset"

  auto_updates true
  depends_on macos: ">= :tahoe"

  app "Kaset.app"

  zap trash: [
    "~/Library/Application Support/Kaset",
    "~/Library/Caches/com.sertacozercan.Kaset",
    "~/Library/Preferences/com.sertacozercan.Kaset.plist",
    "~/Library/Saved Application State/com.sertacozercan.Kaset.savedState",
    "~/Library/WebKit/com.sertacozercan.Kaset",
  ]
end
