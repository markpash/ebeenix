{ pkgs, lib, ... }:

pkgs.devshell.mkShell {
  name = "ebeenix";

  env = [
    {
      name = "PATH";
      prefix = "${pkgs.llvmPackages_16.clang-unwrapped}/bin";
    }
    {
      name ="PKG_CONFIG_PATH";
      eval = "$DEVSHELL_DIR/lib/pkgconfig";
    }
    {
      name = "C_INCLUDE_PATH";
      value = with pkgs; lib.makeSearchPath "include" [
        libbpf
        linuxHeaders
      ];
    }
  ];

  packages = with pkgs; [
    bcc
    bpftools
    ethtool
    gcc
    gnumake
    go_1_21
    iproute2
    libbpf
    llvmPackages_16.bintools-unwrapped
    pkg-config
  ];

  commands = [
    {
      name = "load-c-example";
      command = ''
        clang -O2 -target bpf -c "$PRJ_ROOT"/examples/c/kern.c -o "$PRJ_ROOT"/examples/c/kern.o
        echo "compiled examples/c/kern.o"
        sudo bpftool prog loadall "$PRJ_ROOT"/examples/c/kern.o /sys/fs/bpf/
        echo "loaded examples/c/kern.o into /sys/fs/bpf/"
        sudo bpftool prog show name xdp_pass
      '';
    }
    {
      name = "unload-c-example";
      command = ''
        sudo rm /sys/fs/bpf/xdp_pass
        echo "unloaded /sys/fs/bpf/xdp_pass"
      '';
    }
  ];
}
