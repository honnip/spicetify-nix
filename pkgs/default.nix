{
  lib,
  fetchgit,
  fetchzip,
  fetchFromGitHub,
  callPackage,
  ...
}: let
  source = callPackage ./source.nix {};
  themes = callPackage ./themes.nix source;
  extensions = callPackage ./extensions.nix source;
  apps = callPackage ./apps.nix source;

  # OFFICIAL THEMES AND EXTENSIONS --------------------------------------------

  official = with source; {
    themes = let
      mkOfficialTheme = themeName: {
        ${themeName} = {
          name = themeName;
          src = officialThemes;
        };
      };
    in
      {
        Dribbblish = {
          name = "Dribbblish";
          src = officialThemes;
          requiredExtensions = [extensions.dribbblishExt];
          patches = {
            "xpui.js_find_8008" = ",(\\w+=)32";
            "xpui.js_repl_8008" = ",$\{1}56";
          };
          injectCss = true;
          replaceColors = true;
          overwriteAssets = true;
          appendName = true;
          sidebarConfig = true;
        };

        Dreary = {
          name = "Dreary";
          src = officialThemes;
          sidebarConfig = true;
          appendName = true;
        };
        Glaze = {
          name = "Glaze";
          src = officialThemes;
          sidebarConfig = true;
          appendName = true;
        };
        Turntable = {
          name = "Turntable";
          src = officialThemes;
          requiredExtensions = ["fullAppDisplay.js" extensions.turntableExt];
        };
      }
      // mkOfficialTheme "Ziro"
      // mkOfficialTheme "Sleek"
      // mkOfficialTheme "Onepunch"
      // mkOfficialTheme "Flow"
      // mkOfficialTheme "Default"
      // mkOfficialTheme "BurntSienna";

    extensions = let
      mkOfficialExt = name: {
        "${name}.js" = {
          src = "${officialSrc}/Extensions";
          filename = "${name}.js";
        };
      };
    in
      {
        "dribbblish.js" = extensions.dribbblishExt;
        "turntable.js" = extensions.turntableExt;
      }
      // mkOfficialExt "autoSkipExplicit"
      // mkOfficialExt "autoSkipVideo"
      // mkOfficialExt "bookmark"
      // mkOfficialExt "fullAppDisplay"
      // mkOfficialExt "keyboardShortcut"
      // mkOfficialExt "loopyLoop"
      // mkOfficialExt "popupLyrics"
      // mkOfficialExt "shuffle+"
      // mkOfficialExt "trashbin"
      // mkOfficialExt "webnowplaying";

    apps = {
      new-releases = {
        src = "${officialSrc}/CustomApps";
        name = "new-releases";
      };
      reddit = {
        src = "${officialSrc}/CustomApps";
        name = "reddit";
      };
      lyrics-plus = {
        src = "${officialSrc}/CustomApps";
        name = "lyrics-plus";
      };
    };
  };
in {
  inherit official;
  themes = themes // official.themes;
  apps = apps // official.apps;
  extensions = extensions // official.extensions;
}
