class AitNative < Formula
  desc "Language-neutral native AIT CLI and runner with an inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.4/ait-native-1.1.4-aarch64-apple-darwin.tar.gz"
      sha256 "36d617effdbcf5f05969ffd84c05df195c725270fd9f89919e5163015f989d35"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.4/ait-native-1.1.4-x86_64-apple-darwin.tar.gz"
      sha256 "f0727c7c2678c7f923834d5a56cfce51348f5c74c1c7daf8459a34a26916f4ff"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.4/ait-native-1.1.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "37f212a6264e38e143384026536b50e8432cb52a91958ce6a20be32faddd5024"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.4/ait-native-1.1.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "3b315650640a12aac97e194c8446396ecad6c0b3fc345f5aa58548cd43218ed9"
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
