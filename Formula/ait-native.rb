class AitNative < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0/ait-native-1.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "31c2dc11d566ff27203fccd3853d30708b6ae7ea825f650226549a9e139044bc"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0/ait-native-1.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "5ab966012a4ea96debf581b358e5a2c82fc5f48212b685630c53911ff5c7b2d8"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0/ait-native-1.0.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "4772579b97ad50bce28ceca61c622e004cd7903a9d3bb5b8bbab94561b8c270e"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0/ait-native-1.0.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "58c9ed344a26919bc79f8918a3b757524eb0acd94774cd8074f3d9e8e116631b"
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
      Managed user service: brew services start ait-native
      Service data: #{var}/ait-native/server-data
      Managed CI still requires an admitted memory-backed runtime root.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ait --version")
    assert_match version.to_s, shell_output("#{bin}/ait-server --version")
  end
end
