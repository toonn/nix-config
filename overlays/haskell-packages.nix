self: super:
{ bfpt = (import ~/src/bfpt/default.nix {}).bfpt.components.exes.bfpt;
  coldasdice = (import
    ~/src/coldasdice/default.nix
    {}).coldasdice.components.exes.cadice;
}
