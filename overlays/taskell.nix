self: super: {
  taskell = (super.haskell.lib.unmarkBroken super.taskell).override {
    brick = super.haskell.lib.doJailbreak super.haskellPackages.brick_0_70_1;
  };
}
