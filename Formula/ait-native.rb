class AitNative < Formula
  desc "Language-neutral native AIT CLI and runner with an inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.3/ait-native-1.1.3-aarch64-apple-darwin.tar.gz"
      sha256 "85551e0d3fbd64e8df5ed54b908a4ce96738fa731e6d634df293c520f53ad079"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.3/ait-native-1.1.3-x86_64-apple-darwin.tar.gz"
      sha256 "62c0023aafaed639c3a6cddeb6ae94f0690164f0519709259c7d4f83e6916308"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.3/ait-native-1.1.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "e87b01603000ae3fe5d72878ff9a3c94be67c92a76afcfca31a8e535d060b0bd"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.3/ait-native-1.1.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0caaa85c5898a13ab718f8dba89c7590eeb33c81b5a3f24abe3b2f1ee6f3b7e7"
    else
      odie "unsupported CPU architecture"
    end
  end

  def install
    bin.install "bin/ait"
    bin.install "bin/ait-server"
    bin.install "bin/ait-runner"
    pkgshare.install "share/licenses"
    pkgshare.install "share/ait-native/ait-family-provenance.json"
  end

  service do
    run [
      opt_bin/"ait-server",
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
      ait-runner is installed but no runner daemon is configured or started.
      Inspect the released runner interface with: #{bin}/ait-runner serve --help
      Foreground: #{bin}/ait-server
      Managed user service: brew services start ait-native
      Service data: #{var}/ait-native/server-data
      Managed CI still requires an admitted memory-backed runtime root.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ait --version")
    assert_match version.to_s, shell_output("#{bin}/ait-server --version")
    assert_match version.to_s, shell_output("#{bin}/ait-runner --version")
  end
end
