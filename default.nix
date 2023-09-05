{ compiler ? "ghc8107"
, system ? builtins.currentSystem
, haskellNix ? import
    (builtins.fetchTarball
      "https://github.com/input-output-hk/haskell.nix/archive/1b4bccb032d5a32fee0f5b7872660c017a0748d2.tar.gz")
    { }
, iohkNix ? import
    (builtins.fetchTarball
      "https://github.com/input-output-hk/iohk-nix/archive/edb2d2df2ebe42bbdf03a0711115cf6213c9d366.tar.gz")
    { }
, cardanoPkgs ?
    (builtins.fetchTarball
    "https://github.com/input-output-hk/cardano-haskell-packages/archive/4278da8003518bcd3707c079639a55b58b772947.tar.gz")
, nixpkgsSrc ? haskellNix.sources.nixpkgs-unstable
, nixpkgsArgs ? haskellNix.nixpkgsArgs
}:
let
  pkgs = import nixpkgsSrc (nixpkgsArgs // {
    overlays =
      # iohkNix overlay needed for cardano-api wich uses a patched libsodium
      haskellNix.overlays ++ iohkNix.overlays.crypto;
  });
  musl64 = pkgs.pkgsCross.musl64;
in
musl64.haskell-nix.project {
  compiler-nix-name = compiler;
  projectFileName = "cabal.project";
  inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = cardanoPkgs; };
  sha256map = {
    "https://github.com/CardanoSolutions/direct-sqlite.git"."82c5ab46715ecd51901256144f1411b480e2cb8b" = "fuKhPnIVsmdbQ2gPBTzp9nI/3/BTsnvNIDa1Ypw1L+Q=";
    "https://github.com/CardanoSolutions/text-ansi.git"."dd81fe6b30e78e95589b29fd1b7be1c18bd6e700" = "mCFkVltVeOpDfEkQwClEXFAiOV8lSejmrFBRQhmeLDE=";
  };
  src = musl64.haskell-nix.haskellLib.cleanSourceWith {
    name = "kupo-src";
    src = ./.;
    filter = path: type:
      builtins.all (x: x) [
        (baseNameOf path != "package.yaml")
      ];
  };
}
