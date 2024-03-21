# gdtilemap
Example of importer for Team17 map from Amiga games

## SuperFrog CD32 version
All game assets are located in `data` folder, compressed using [Imploder 4.0](https://aminet.net/package/util/pack/imploder-4.0).  
There are 6 levels (worlds) in game, assets files per level have prefix "L" and level number e.g. "L1".  
Each file has suffix depending on purpose of file:
- `BM` is tile set as IFF image 320x672 5bpp full file name e.g.
	- L1BM
- `BO` are enemy sprites as IFF image full file name e.g.
	- L1BO
- `ET` is level end title screen as IFF image full file name e.g.
	- L1ET
- `FX` is level SoundFx, unknown format full file name e.g.
	- L1FX
- `LP` is level loading screen as IFF image full file name e.g.
	- L1LP
- `MA` is tile map, includes number e.g. MA1, MA2... full file name e.g.
	- L1MA1
	- L1MA2
	- L1MA3
	- L1MA4
- `MS` tiles collision masks as raw image 320x672 1bpp full file name e.g.
	- L1MS
- `MU` is level music as ProTracker module packed format, recognizable by the P41A magic bytes full file name e.g.
	- L1MU

## References
- [Tiled - tile map editor](https://www.mapeditor.org/)
- [Tiled - godot importer](https://github.com/Kiamo2/YATI/tree/main)
- [Froggy - SuperFrog level editor](https://sourceforge.net/projects/superfrog/)