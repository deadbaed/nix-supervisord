{
  sources ? import ./npins,
  pkgs ? import sources.nixpkgs { },
}:

let
in
rec {
  shell = pkgs.mkShellNoCC {
    buildInputs = with pkgs; [
      npins
      lnav
      nixfmt-tree
    ];
  };
}
