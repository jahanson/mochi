# jahanson's homelab

## Goals

-   [ ] Learn nix
-   [ ] Services I want to separate from my kubernetes cluster I will use Nix.
-   [ ] Approval-based update automation for flakes.
-   [ ] Expand usage to other shell environments such as WSL, etc
-   [ ] keep it simple, use trusted boring tools

## TODO

-   [x] Forgejo Actions
-   [ ] Bring over hosts
    -   [x] Varda (forgejo)
    -   [x] Thinkpad T470
    -   [x] Legion 15 AMD/Nvidia
    -   [x] Telperion (network services)
    -   [ ] Gandalf (NixNAS)

## Links & References

-   [truxnell/dotfiles](https://github.com//truxnell/nix-config/)
-   [billimek/dotfiles](https://github.com/billimek/dotfiles/)

## Upgrading the borgmatic template for reference

```sh
borgmatic config generate --source nixos/hosts/shadowfax/config/borgmatic/borgmatic-template.yaml --destination nixos/hosts/shadowfax/config/borgmatic/borgmatic-t
emplate.yaml  --overwrite
```
