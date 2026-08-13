class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.4/ait-native-1.0.0-rc.4-aarch64-apple-darwin.tar.gz"
      sha256 "fbc7fc9f3baced6611e22f7f6917567705a8037042685b4184b04ea8c1b80602"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.4/ait-native-1.0.0-rc.4-x86_64-apple-darwin.tar.gz"
      sha256 "f3e2a94f69d5563da38a2a355d7e920f1b3e89565bf1d5b902869b0c731b59a4"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.4/ait-native-1.0.0-rc.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6e70a068ae271a5e6580c9c5c1a5a2d92843889e9a437e2692577085506d545b"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.4/ait-native-1.0.0-rc.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "67efb6c56712fd39da5cbf2f771fb5839b34b15234689282f0c730569e7fff9c"
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
