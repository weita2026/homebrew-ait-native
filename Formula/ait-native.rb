class AitNative < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.0/ait-native-1.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "4f3e02c932bbf29c24560a9268ca6ce2aabacea5bc3dcb7908ccefc7b6c55a31"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.0/ait-native-1.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "4a59d44e8ef27444164020c7992a9b73b4de463a33ca916c3c3b1221d413ab50"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.0/ait-native-1.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9f77fade2109d7288da169ce724f1b80ee4047b2285dd0f0c5fc1fd7589588bd"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.0/ait-native-1.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "356ac2c7052f61f66aa0aa7704e576b27dccb30987af9a67c5788d1ff85ec603"
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
      Foreground: #{bin}/ait-server
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
