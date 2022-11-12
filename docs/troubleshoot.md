# Troubleshoot

## Outstanding issues

- [ ] poor terminal resolution with `nvidia` driver - (but doesn't occur with work computer that has GTX 1080ti)
- [x] [Alacritty emojis](https://github.com/jwilm/alacritty/issues/153) - working with `noto-fonts-emoji`
- [ ] [vscode titlebar](https://github.com/microsoft/vscode/issues/43154)
- [ ] [xmodmap bindings not respected in vscode](https://github.com/microsoft/vscode/issues/23991)
- [ ] [Unable to select all in Rofi](https://github.com/davatorium/rofi/issues/666)
- [ ] [Kawase blur](https://github.com/yshui/picom/issues/32)
- [ ] [`broot`/`br` uses `rm`](https://github.com/Canop/broot/issues/136) (but I've crippled `rm` with an alias)

## General

### System Time

Especially with dual booting, I've had to [configure Windows to use UTC](https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows) or [force my clock to the correct time](https://wiki.archlinux.org/index.php/System_time#Clock_shows_a_value_that_is_neither_UTC_nor_local_time).

### Graphics

Trouble with tearing with nouveau via `mesa`, may need to use `nvidia` instead.

#### Firefox

`about:config`

```
layers.acceleration.force-enabled = true
```

## Laptop

### Graphics

#### With GPU

[Hybrid graphics](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_P1#Installation_with_hybrid_graphics)

For enhanced graphics, explore something like [this](https://www.reddit.com/r/linux_gaming/comments/5t8qb3/guide_how_i_fixed_every_problem_i_had_with_nvidia/)

For a simple solution, just install [Bumblebee](https://wiki.archlinux.org/index.php/Bumblebee#Installation).

#### Graphics

The `Tearfree` option may be required.

```
Section "Device"
    Identifier    "Card1"
    # pick between "modesetting" and "intel" here (intel requires xf86-video-intel)
    Driver        "intel"
    Option        "Tearfree" "true"
    BusID        "PCI:0:2:0"
EndSection
```

### Input

[Touchpad tap to click](https://wiki.archlinux.org/index.php/Libinput#Installation)
