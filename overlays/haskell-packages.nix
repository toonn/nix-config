self: super:
{ arbtt = super.buildEnv {
    name = "arbtt";
    paths = super.lib.attrsets.attrValues (import ~/opt/arbtt/default.nix {});
  };
  bfpt = (import ~/src/bfpt/default.nix {}).bfpt.components.exes.bfpt;
  coldasdice = (import
    ~/src/coldasdice/default.nix
    {}).coldasdice.components.exes.cadice;
}
