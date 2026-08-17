class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.10/ait-native-1.0.0-rc.10-aarch64-apple-darwin.tar.gz"
      sha256 "f5d7ef4032a8895d4def5eeb7d67f663d864787d9296b9e101155abb486c357b"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.10/ait-native-1.0.0-rc.10-x86_64-apple-darwin.tar.gz"
      sha256 "082ce4347e8e2a4bfe05a4360532d6f0a52669a0f9657e3b60c270b50619bd30"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.10/ait-native-1.0.0-rc.10-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "57db97edcc3f1c7174a2639f1817e648f336701fb0159c29ba5eb2b85323d0de"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.10/ait-native-1.0.0-rc.10-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e45ba7e7d05520c1a7747f2f2a7a1da849d6f78f8abf8fe4344bd646cc1bae4a"
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
