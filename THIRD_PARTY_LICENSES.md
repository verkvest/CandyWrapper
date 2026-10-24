# Liltkin credits and licenses

Liltkin is a portrait phone port of an open-source looping platformer.
The playfield is the original 144×144 game. Touch buttons sit outside that square.

The name on the store and on the home screen is Liltkin.
Bundle id (iOS and Android): es.verkvest.liltkin

## Original game

Copyright (c) 2025 Harmony Honey Monroe

The game code, pixel art, sound effects, and soundtrack in this repository are
Harmony Honey Monroe's work, published under the MIT license below. The game
was first released in 2018 and later ported to Godot by the same author.

What was checked:

- LICENSE at the root of this repo is the MIT license signed by Harmony Honey Monroe.
- Pixel art under media/image (sprites, tiles, title card, icons the author drew)
  ships in that tree with no separate license and no third-party watermark.
  The title card still shows the author's "BY HARMONY HONEY" credit.
  The old wordmark on that card was redrawn in-repo for the Liltkin name.
  The character, banner, and end cards are unchanged.
- Sound effects (Jump.ogg, Death.ogg, Win.ogg, Lose.wav) are short original
  effects. The itch.io page lists bfxr as a tool the author used to make them.
  bfxr itself is not bundled.
- media/audio/OST.mp3 has no ID3 tags. It was added to the upstream repo by
  HarmonyHoney (first as OST.ogg, then re-encoded to mp3). On the itch.io page
  the author wrote that they produced the track in Reason 10 and called it EDM.
  It is not a ripped commercial recording. It stays, under the same MIT grant.
- No font files are bundled. Phone UI uses the Godot engine's built-in font,
  which is covered by the engine license.
- The default Godot mascot file that shipped as icon.svg is replaced with an
  original icon drawn by tools/make_icons.py. Launcher icons under branding/
  are generated from that script.
- linux/net.hhoney.candy.metainfo.xml declares its own metadata license as
  CC0-1.0. That applies to the AppStream metadata, not to the game.
  The metainfo "project_license" line still says Unlicense; the license file
  in this repo is MIT. Both allow commercial redistribution. The MIT notice
  below is the one to keep with the game.

### MIT license (original game)

Copyright (c) 2025 Harmony Honey Monroe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Godot Engine

This game runs on Godot Engine, used under the MIT license.
https://godotengine.org

Copyright (c) 2014-present Godot Engine contributors.
Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Portions of Godot Engine may include other permissive notices (zlib, BSD, and
similar) shipped with the engine binary. Those notices are in the engine's
COPYRIGHT.txt and are not modified by this project.

## Tools used by the original author (not bundled)

- Godot Engine
- Aseprite (pixel art)
- bfxr (sound effects)
- Reason 10 (soundtrack)

## AppStream metadata

linux/net.hhoney.candy.metainfo.xml is marked metadata_license CC0-1.0 by its author.
https://creativecommons.org/publicdomain/zero/1.0/
