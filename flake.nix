{
  description = "A flake for the epc.sh script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages = let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      default = pkgs.stdenv.mkDerivation {
        name = "epc";
        src = ./.;

        buildInputs = [
          pkgs.bash
          pkgs.curl
          pkgs.drill
          pkgs.coreutils
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp ${./epc.sh} $out/bin/epc.sh
          chmod +x $out/bin/epc.sh
        '';

        meta = with pkgs.lib; {
          description = "A script to check the availability of a URL and compare hash values";
          license = licenses.gpl3;
          maintainers = with maintainers; [ suorcd ];
        };
      };
    };
  };
}