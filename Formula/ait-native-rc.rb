class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.9/ait-native-1.0.0-rc.9-aarch64-apple-darwin.tar.gz"
      sha256 "81af70d218e791d51967853632d7346aeeee0b12729ac6cd13071ab1ef5c4347"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.9/ait-native-1.0.0-rc.9-x86_64-apple-darwin.tar.gz"
      sha256 "24dd5db1e05c9a2e468bd0d782aeb929c3d9f9fde75cfa0557894c80f357fa29"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.9/ait-native-1.0.0-rc.9-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "1875f431b284a5b71940b77d55d9770e5c94019dbf671910d1bbb2e4b94c925d"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.9/ait-native-1.0.0-rc.9-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "ad927d0d86e02756138f51ef62e1f3e7ee01b20e0c1ed582ee57663f61612409"
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
