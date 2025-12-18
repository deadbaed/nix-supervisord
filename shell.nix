{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    npins
    nixfmt-tree
    nil
    nixfmt-rfc-style
  ];
}
