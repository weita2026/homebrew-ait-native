class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  version "1.0.0-rc.1"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.1/ait-native-1.0.0-rc.1-aarch64-apple-darwin.tar.gz"
      sha256 "e879e193b93459ecc9b5866bb9a914f2a1a327291f3568b919e1216418a9cd24"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.1/ait-native-1.0.0-rc.1-x86_64-apple-darwin.tar.gz"
      sha256 "c30bd2d90b6f16d34f78d44b7fcc4164a7c5de9017c4ad27ed324f059816a249"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.1/ait-native-1.0.0-rc.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6250b65bdb8fe041add9f66c620597ac06879151962f792de99d61606a1adcca"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.1/ait-native-1.0.0-rc.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c988f1344f45bc3f7ed76c453012f171e3932fd687be60ce85ef719a72ddbf89"
    else
      odie "unsupported CPU architecture"
    end
  end

  def install
    bin.install "bin/ait"
    bin.install "bin/ait-server"
    pkgshare.install "share/licenses"
    pkgshare.install "share/ait-native/ait-family-provenance.json"
  end

  service do
    run [opt_bin/"ait-server", "run", "--data", var/"ait-native/server-data", "--init-if-missing", "--defer-ci-admission"]
    keep_alive true
    log_path var/"log/ait-server.log"
    error_log_path var/"log/ait-server.error.log"
  end

  def caveats
    <<~EOS
      ait-server is installed but remains inactive until explicitly started.
      Foreground: #{bin}/ait-server run
      Managed user service: brew services start ait-native-rc
      Service data: #{var}/ait-native/server-data
      Managed CI still requires an admitted memory-backed runtime root.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ait --version")
    assert_match version.to_s, shell_output("#{bin}/ait-server --version")
  end
end
