class AitNative < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.1/ait-native-1.0.1-aarch64-apple-darwin.tar.gz"
      sha256 "6dc5e30e8b8f2b9776c2d388c81d4e0122615d4fdd75efed5d568424a0bf6c72"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.1/ait-native-1.0.1-x86_64-apple-darwin.tar.gz"
      sha256 "33e359f5a4f192faeefdf6fc6e0a7902efadb6937fd287b5b68f83ddeb335bbf"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.1/ait-native-1.0.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "431da922893534ad3f677b76ee1fac3a752d0ce953cf800f1eab367615845c44"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.1/ait-native-1.0.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "5a649c4f872b6c436fe96d9ed54dbbae4e2a8498e9ffc80b62f078c10f5dd1ef"
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
