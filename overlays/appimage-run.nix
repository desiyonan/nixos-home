# FHS /etc/profile 会先 export 一份 appimage-run-fhsenv 的 PS1。
# profile 追加在那段之后，用同一份提示符把它盖掉。
{ ... }:

final: prev:
let
  prompt = final.mesh.dotfs.shell.prompt;
in
{
  appimage-run = prev.appimage-run.override (old: {
    buildFHSEnv =
      args:
      old.buildFHSEnv (
        args
        // {
          profile = ''
            ${args.profile or ""}
            ${prompt}
          '';
        }
      );
  });
}
