self: super: {
  beidconnect = super.beidconnect.overrideAttrs (oAs: let version = "2.12"; in {
    inherit version;
    src = super.fetchFromGitHub ({
      inherit (oAs.src) owner repo;
      rev = version;
      hash = "sha256-ZFxq/rJP0/KSsi2qsXyKY9Fmb+JxeakTdso5FsVu1/c="; });
    }
  );
}
