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

puts derive_rust_toolchain_from_rbconfig(ARGV.first)
