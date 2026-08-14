class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.6/ait-native-1.0.0-rc.6-aarch64-apple-darwin.tar.gz"
      sha256 "4333e5efc9b32a1b9f3096d408326f6bc102062f95459c5582256b4aa3711278"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.6/ait-native-1.0.0-rc.6-x86_64-apple-darwin.tar.gz"
      sha256 "0c280bc7895503e42471751be311082da996249dbefee3f306f8733e0079f915"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.6/ait-native-1.0.0-rc.6-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "801a21a50ae5dd6a60d697ffb91c775fd9b41107af2a08bb0ff2ec4908c16166"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.6/ait-native-1.0.0-rc.6-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "766fb0c301ba9ddcf619ec1c0f4b57a5ba3eb88c5fff48943ac5419898930199"
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
    run [
      opt_bin/"ait-server",
      "run",
      "--data",
      var/"ait-native/server-data",
      "--init-if-missing",
      "--defer-ci-admission",
    ]
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
