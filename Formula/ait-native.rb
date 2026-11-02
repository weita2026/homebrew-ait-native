class AitNative < Formula
  desc "Language-neutral native AIT CLI and runner with an inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.2.0/ait-native-1.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "64437112f7a9f650cf04df612ea07994c5d538981bcd665d92899ebc1e294d8b"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.2.0/ait-native-1.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "90bda36855ea58af475558788195d07ecc5659b1ef3ded47740cd746ef749c30"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.2.0/ait-native-1.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c5ce7952d70f2b2ff844466a660a1c94f8a47a7ffc7c19e9c09e78cad65a1779"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.2.0/ait-native-1.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "30bdb29715d4580ad1be6ac9c56301c760ee0eb24127592096a71be4127fd64d"
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
