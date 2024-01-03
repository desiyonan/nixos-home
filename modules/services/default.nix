{lib, ...}:
with lib;
{
  imports =  builtins.map
    (f: ./. + "/${f}")
    (builtins.attrNames
      (filterAttrs
        (name: type: type == "directory")
        (builtins.readDir ./.)
      )
    );
}
