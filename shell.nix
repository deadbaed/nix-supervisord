{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:

pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    npins
    lnav
    nixfmt-tree
  ];
}
