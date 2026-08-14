class AitNativeRc < Formula
  desc "Language-neutral native AIT CLI and inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.5/ait-native-1.0.0-rc.5-aarch64-apple-darwin.tar.gz"
      sha256 "5b780259aba6fb11f3404b5236072be89a45ee10812bc7a186a92fdf9925779f"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.5/ait-native-1.0.0-rc.5-x86_64-apple-darwin.tar.gz"
      sha256 "eccfb5c610638d8d0fa9d351fb5c506f4f7539748c1f668c24b3cacf4c108b00"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.5/ait-native-1.0.0-rc.5-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c79d509616431d92a66c21f6b9135c93e5601ec8519796df9f876dad483b3ebf"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.0.0-rc.5/ait-native-1.0.0-rc.5-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "650ef8ded04e7e3ebcc4d609fca1917bb1229507bd2afa3f33d3083a994210fb"
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
