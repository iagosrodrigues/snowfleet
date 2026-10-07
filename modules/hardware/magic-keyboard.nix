_: {
  flake.modules.nixos.magic-keyboard = {
    # Apple Magic Keyboard (hid_apple): F1-F19 send function keys without Fn
    # (media keys via Fn), and Option/Command swapped to PC Alt/Super order.
    boot.extraModprobeConfig = ''
      options hid_apple fnmode=2 swap_opt_cmd=1
    '';
  };
}
