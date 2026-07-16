-- Nix Logo — display the Nix logo (or any image) in the bar.
-- New-format entry: the manifest lives in plugin.toml, and this file only
-- handles presentation.

barWidget.setImage(noctalia.getConfig("image_path"))
