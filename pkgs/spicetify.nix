{
  lib,
  stdenv,
  spotify,
  spicetify-cli,

  # These are throw's for callPackage to be able to get to the override call
  theme ? throw "",
  config-xpui ? { },
  customColorScheme ? { },
  cssMap ? "${spicetify-cli.src}/css-map.json",
  extensions ? [ ],
  apps ? [ ],
  extraCommands ? "",
}@args:

spotify.overrideAttrs (old: {
  name = "spicetify-${theme.name}";

  postInstall =
    (old.postInstall or "")
    + ''
      export SPICETIFY_CONFIG=$PWD

      mkdir -p {Themes,Extensions,CustomApps}

      cp -r ${theme.src} Themes
      chmod -R a+wr Themes

      ${lib.optionalString (theme ? additionalCss) ''
        cat << EOF >> Themes/${theme.name}/user.css
          ${"\n" + theme.additionalCss}
        EOF
      ''}

      # extra commands that the theme might need
      ${theme.extraCommands or ""}

      # copy extensions into Extensions folder
      ${lib.concatMapStringsSep "\n" (item: "cp -rn ${item.src}/${item.name} Extensions") extensions}

      # copy custom apps into CustomApps folder
      ${lib.concatMapStringsSep "\n" (item: "cp -rn ${item.src} CustomApps") apps}

      # add a custom color scheme if necessary
      ${lib.optionalString (customColorScheme != { }) ''
        cat ${
          builtins.toFile "spicetify-colors.ini" (lib.generators.toINI { } { custom = customColorScheme; })
        } > Themes/${theme.name}/color.ini
      ''}


      cp ${lib.getExe spicetify-cli} spicetify 
      ln -s ${lib.getExe' spicetify-cli "jsHelper"} jsHelper
      ln -s ${cssMap} css-map.json

      touch prefs

      # replace the spotify path with the current derivation's path
      sed "s|__SPOTIFY__|${
        if stdenv.isLinux then
          "$out/share/spotify"
        else if stdenv.isDarwin then
          "$out/Applications/Spotify.app/Contents/Resources"
        else
          throw ""
      }|g; s|__PREFS__|$SPICETIFY_CONFIG/prefs|g" ${
        builtins.toFile "spicetify-confi-xpui" (lib.generators.toINI { } config-xpui)
      } > config-xpui.ini


      ${extraCommands}

      ./spicetify --no-restart backup apply
    '';

  passthru =
    # For debugging purposes
    (old.passthru or { })
    // builtins.removeAttrs args [
      "lib"
      "stdenv"
    ];
})
