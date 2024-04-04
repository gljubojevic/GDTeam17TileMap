# Godot Team17 TileMap
Example of importer for Team17 maps from Amiga games
Games using map format:
- SuperFrog
- AlienBreed
- ProjectX

## SuperFrog CD32 version
SuperFrog Amiga long play video
https://www.youtube.com/watch?v=V1R7Pd329Bc

Imported SuperFrog map example is hosted on project GitHub pages:  
https://gljubojevic.github.io/GDTeam17TileMap/

Controls:
- Arrow Left - Move left
- Arrow Right - Move right
- Arrow Up - Jump


Game assets are located in `data` folder, compressed using [Imploder 4.0](https://aminet.net/package/util/pack/imploder-4.0).  
There are 6 levels (worlds) in game, assets files per level have prefix "L" and level number e.g. "L1".  
Each file has suffix depending on purpose of file:
- `BM` is tile set image 320x672 5bpp full file name e.g.
	- L1BM, converted to png for example L1BM.png
- `BO` are enemy sprites image full file name e.g.
	- L1BO, converted to png for example L1BO.png
- `ET` is level end title screen image full file name e.g.
	- L1ET, not used in example
- `FX` is level SoundFx, unknown format full file name e.g.
	- L1FX, not used in example
- `LP` is level loading screen image full file name e.g.
	- L1LP, not used in example
- `MA` is tile map, includes number e.g. MA1, MA2... full file name e.g.
	- L1MA1, added extension .t7mp for importer L1MA1.t7mp
	- L1MA2, added extension .t7mp for importer L1MA2.t7mp
	- L1MA3, added extension .t7mp for importer L1MA3.t7mp
	- L1MA4, added extension .t7mp for importer L1MA4.t7mp
- `MS` tiles collision masks as raw image 320x672 1bpp full file name e.g.
	- L1MS, converted to png for example L1MS.png
- `MU` is level music as ProTracker module packed format, recognizable by the P41A magic bytes full file name e.g.
	- L1MU, not used in example

## References
- [team17](https://www.team17.com/)
- [Tiled - tile map editor](https://www.mapeditor.org/)
- [Tiled - godot importer](https://github.com/Kiamo2/YATI/tree/main)
- [Froggy - SuperFrog level editor](https://sourceforge.net/projects/superfrog/)
- [godot-ci - build on github](https://github.com/abarichello/godot-ci)
- [coi-serviceworker - to alow hosting on GitHub Pages without COOP and COEP headers](https://github.com/gzuidhof/coi-serviceworker)
