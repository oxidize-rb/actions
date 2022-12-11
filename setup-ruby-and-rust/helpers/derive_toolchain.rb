require "rbconfig"

def derive_rust_toolchain_from_rbconfig(input_rust_toolchain)
  return input_rust_toolchain if input_rust_toolchain.count("-") >= 3 # already a full toolchain

  case RbConfig::CONFIG["host_os"]
  when /mingw/
    "#{input_rust_toolchain}-x86_64-pc-windows-gnu"
  when /mswin/
    "#{input_rust_toolchain}-x86_64-pc-windows-msvc"
  else
    input_rust_toolchain
  end
end

if ARGV.include?("--runner")
  case RbConfig::CONFIG["host_os"]
  when /mingw|mswin/
    puts "x86_64-pc-windows-msvc"
  when /darwin/
    puts "x86_64-apple-darwin"
  when /linux/
    puts "x86_64-unknown-linux-musl"
  end
else
  puts derive_rust_toolchain_from_rbconfig(ARGV.first)
end

