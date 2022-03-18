Hexen II hcode versions:
------------------------------------------------------------------------
h2-1.11 and portals-1.12a are the official hcode releases from Raven. I
generated the other versions by decompiling the relevant progs and then
comparing to h2-1.11 and experimenting.  All the sources compile to
output precisely the same progs.dat as the original binary ones.

These have been good reference material for me when working on uHexen2 -
Hammer of Thyrion, therefore I am sharing them.

* h2-0.42-demo	 HexenC source for Hexen II demo v0.42 from Aug. 1997
* h2-1.03	 HexenC source for Hexen II retail version (PC CD-ROM)
* h2-1.09	 HexenC source for Hexen II v1.09 update
* h2-1.10	 HexenC source for Hexen II v1.10 (from Matrox m3D cd
				a.k.a. Continent of Blackmarsh, v1.10)
* h2-1.11	 HexenC source for Hexen II v1.11 update (official)
* h2-1.11-demo	 HexenC source for Hexen II demo v1.11 from Nov. 1997
* portals-1.12	 HexenC for Portal of Praevus mission pack (ver.cdrom)
* portals-1.12a	 HexenC for Portal of Praevus 1.12a update (official)

* e3-beta	 HexenC source code for E3-beta version of Hexen II.
				(See e3-beta/README.txt for details.)

I don't have access to 1.08 version, the original Matrox m3D bundled
version of Hexen II, a.k.a. Continent of Blackmarsh.  Therefore that
information is missing here.

Diff outputs between several versions:
* h2-v0.42-demo_to_h2-v1.03.diff
* h2-v1.03_to_h2-v1.09.diff
* h2-v1.03_to_h2-v1.11.diff
* h2-v1.09_to_h2-v1.10.diff
* h2-v1.09_to_h2-v1.11.diff
* h2-v1.10_to_h2-v1.11.diff
* h2-v1.11_to_h2-v1.11-demo.diff

Hexen2World hcode versions:
------------------------------------------------------------------------
hw-src-release is the official hcode release from Raven.  I generated
the other versions by decompiling the relevant progs and then comparing
to hw-src-release and experimenting. All the sources compile to output
precisely the same hwprogs.dat as the original binary ones.

The only difference between the hw-0.15 binary release and the later
hwsource release is that the EF_BRIGHTFIELD and EF_ONFIRE: the original
binary releases had them as 1 and 1024 respectively, but the later src
releases have the flipped: EF_BRIGHTFIELD = 1024 and EF_ONFIRE = 1,
which is a BIG BOO BOO. The hexenworld engine source release also have
EF_BRIGHTFIELD as 1024 and EF_ONFIRE as 1, therefore uHexen2 sticks to
those values.

* hw-0.09	  HexenC source for HexenWorld v0.09 binary release
		    (ancient release. AFAIK, the initial hw release.)
* hw-0.11	  HexenC source for HexenWorld v0.11 binary release
* hw-0.14	  HexenC source for HexenWorld v0.14 binary release
* hw-0.15	  HexenC source for HexenWorld v0.15 binary release
* hw-src-release  The official HexenC source release for HexenWorld

Diff outputs between several versions:
--------------------------------------
* hw-v0.09_to_hw-v0.11.diff
* hw-v0.11_to_hw-v0.14.diff
* hw-v0.14_to_hw-v0.15.diff
* hw-v0.15_to_hw-v0.15.1.diff  (hw-0.15 release <-> hw-src-release.)

HexenWorld Siege hcode versions:
------------------------------------------------------------------------
siege-src-release is the official hcode release from Raven. I generated
the other versions by decompiling the relevant progs and then comparing
to siege-src-release and experimenting.  All generated sources compile
to output precisely the same hwprogs.dat as the original binary ones.
The official siege documentation has mention of a siege 0.13 version
but I couldn't locate it so far: 0.14 and the latest 0.15 are the only
binary releases I have access to.

* siege-0.14		HexenC source for Siege v0.14 binary release
* siege-0.15		HexenC source for Siege v0.15 binary release
* siege-src-release	Official HexenC source release for HW/Siege mod

Diff outputs between several versions:
--------------------------------------
* siege-v0.14_to_siege-v0.15.diff
* siege-v0.15_to_siege-v0.15.x.diff (siege-0.15 <-> siege-src-release.)

--
sezero[at]users[dot]sourceforge[dot]net
