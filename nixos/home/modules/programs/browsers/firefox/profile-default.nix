{pkgs}: {
  id = 0;
  name = "default";
  isDefault = true;
  settings = {
    "browser.startup.homepage" = "https://status.hsn.dev";
    "browser.search.suggest.enabled.private" = false;
    # 0 => blank page
    # 1 => your home page(s) {default}
    # 2 => the last page viewed in Firefox
    # 3 => previous session windows and tabs
    "browser.startup.page" = "3";
    "browser.send_pings" = false;
    "browser.display.use_system_colors" = "true";
    "browser.display.use_document_colors" = "false";
    "devtools.theme" = "dark";
    "extensions.pocket.enabled" = false;
  };
  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    ublock-origin
    privacy-badger
    refined-github
    kagi-search
    languagetool
    onepassword-password-manager
    streetpass-for-mastodon
    dearrow
    sponsorblock
  ];
}
