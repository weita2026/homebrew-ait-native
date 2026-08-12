class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  version "1.0.0-rc.2"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.2/ait-native-1.0.0-rc.2-aarch64-apple-darwin.tar.gz"
      sha256 "e3dce0578dd29e09c68872c813fddf6fd110a4be8ad62161c5b60cbaf872ee12"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.2/ait-native-1.0.0-rc.2-x86_64-apple-darwin.tar.gz"
      sha256 "18476da42feea0811abdf8e99ea5f5fe91aefa523846eaf27422537aae2fea9c"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.2/ait-native-1.0.0-rc.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "7b4c4181abf073f1a0d77401afac4210c8bd507a9e42568f9a711efc25f8d6ce"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.2/ait-native-1.0.0-rc.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "7b4448e7d33bad2e468178217ef5bcfa4b862e477b5d8b52eb4b1d44dcdb5ffe"
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
