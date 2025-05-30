{
  lib,
  writers,
  runCommand,
}:
let
  inherit (builtins)
    all
    match
    attrNames
    ;
  inherit (lib)
    importJSON
    ;

  lockFile = importJSON ../../flake.lock;
  nixpkgsLock =
    # Assert there is only one nixpkgs node
    assert all (node: match "nixpkgs_[0-9]+" node == null) (attrNames lockFile.nodes);
    lockFile.nodes.nixpkgs.original;

  info = {
    inherit (lib.trivial) release;
    nixpkgs_rev = lib.trivial.revisionWithDefault (throw "nixpkgs revision not available");
    unstable = lib.strings.hasSuffix "-unstable" nixpkgsLock.ref;
  };
in
runCommand "version-info.toml" { } ''
  (
    echo "# DO NOT MODIFY!"
    echo "# This file was generated by ${
      lib.strings.removePrefix (toString ../.. + "/") (toString ./default.nix)
    }"
    cat ${writers.writeTOML "version-info.toml" info}
  ) > $out
''
