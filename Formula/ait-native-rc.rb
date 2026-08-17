class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.8/ait-native-1.0.0-rc.8-aarch64-apple-darwin.tar.gz"
      sha256 "4133251e4b5fc79f733a015447abd90a4816d20f8a6cc3f5ff6eed5030538dcd"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.8/ait-native-1.0.0-rc.8-x86_64-apple-darwin.tar.gz"
      sha256 "dbebf5c4194878a5fb771084670644c7b799e963d04254d0d77645cd8a7228c4"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.8/ait-native-1.0.0-rc.8-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c6b8ac6674f8fd3200a25e018398406bfdf878c3df44a204f1111b9b40363a29"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.8/ait-native-1.0.0-rc.8-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2b1fbb96e5ba96fb8d98ab6a32cd7633bf4a40f72cf9b4248420fb55c731c6d0"
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
