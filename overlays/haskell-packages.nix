self: super:
{ bfpt = (import /home/toonn/src/bfpt/default.nix {}).bfpt.components.exes.bfpt;
  coldasdice = (import
    /home/toonn/src/coldasdice/default.nix
    {}).coldasdice.components.exes.cadice;
}
