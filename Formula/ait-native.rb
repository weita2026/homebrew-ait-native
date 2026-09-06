class AitNative < Formula
  desc "Language-neutral native AIT CLI and runner with an inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.2/ait-native-1.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "236414607c04fe2f65e0b6699d0397da965ba9cc19dc98cf5bcbc1574143f10b"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.2/ait-native-1.1.2-x86_64-apple-darwin.tar.gz"
      sha256 "f97dcfc8262b4f0c23168e5d9e9b1642d52dd3aaacb4ad8f6d2689d889babbce"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.2/ait-native-1.1.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "433955a7b4aec189dea4228c2e145836cadbe20acc30520e881e06cc99c55fd3"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.2/ait-native-1.1.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "85ebfe624e487474a58ad5c2d5c9ac1d1224afeddcb9e94bbd4e7095a0be8f23"
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
