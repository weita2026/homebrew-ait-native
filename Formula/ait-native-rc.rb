class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  version "1.0.0-rc.3"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.3/ait-native-1.0.0-rc.3-aarch64-apple-darwin.tar.gz"
      sha256 "59d670579271fa9a687e6ce1878e7ae0f8116c11c0448f3e932193eac9df4caf"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.3/ait-native-1.0.0-rc.3-x86_64-apple-darwin.tar.gz"
      sha256 "1ff74c2465d999906ab93db8d8d90fb5e39a78b54acb1cacac8be01012a7752c"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.3/ait-native-1.0.0-rc.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "adafb65639230a4a86c437ff988d3795eaa7a20eb6f8eb26cb7747a9b90379d9"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.3/ait-native-1.0.0-rc.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "97480fef13f2fe92f62c146c8bfb5ac562e7efd49e01bd92172d19d400388ebc"
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
