class AitNative < Formula
  desc "Language-neutral native AIT CLI and runner with an inactive self-hosted server"
  homepage "https://github.com/weita2026/ait-native"
  license all_of: ["AGPL-3.0-only", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.1/ait-native-1.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "e6758feded0b2eca0894af11f823b1549ade655d1245479c872d461fab2b7443"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.1/ait-native-1.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "480b485d76853e0cefde8cf04e064dba14cbee3e4e764bb4459fb10663539362"
    else
      odie "unsupported CPU architecture"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.1/ait-native-1.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "80143968f47899363232e3f2a333f2cc32a0f8da5567ab186e30de4bab48263c"
    elsif Hardware::CPU.intel?
      url "https://github.com/weita2026/ait-native/releases/download/v1.1.1/ait-native-1.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "93b689a1869251532c18f1733def611fd5570f8ace47a9320baf603fb873dece"
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
