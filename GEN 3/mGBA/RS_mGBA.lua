local Game = {
	new = function (self, game)
		self.__index = self
		setmetatable(game, self)
		return game
	end
}

-- Transform to string
function Game.toString(game, rawstring)
	local string = ""
	for _, char in ipairs({rawstring:byte(1, #rawstring)}) do
		if char == 0xFF then
			break
		end
		--string = string..game._charmap[char]
		if emu.memory.cart0:read8(0xAF) == 0x4A then
			string = string..game._charmapJP[char]
		else
			string = string..game._charmap[char]
		end
	end
	return string
end

-- Pokemon names
function Game.getSpeciesName(game, id)
	local pointer = game._speciesNameTable + 11 * id
	return game:toString(emu.memory.cart0:readRange(pointer, 10))
end

-- List of nature
function Game.getNature(game, nat)
	local temp, pos, neg = {"","","","",""}, math.floor(nat/5), nat%5
	if emu.memory.cart0:read8(0xAF) == 0x44 then
		List = {"ROBUST", "SOLO", "MUTIG", "HART", "FRECH",
			"KÜHN", "SANFT", "LOCKER", "PFIFFIG", "LASCH", "SCHEU", "HASTIG", "ERNST", "FROH", "NAIV",
			"MÄẞIG", "MILD", "RUHIG", "ZAGHAFT", "HITZIG", "STILL", "ZART", "FORSCH", "SACHT", "KAUZIG"} -- Deutsch
	elseif emu.memory.cart0:read8(0xAF) == 0x46 then
		List = {"HARDI", "SOLO", "BRAVE", "RIGIDE", "MAUVAIS",
			"ASSURÉ", "DOCILE", "RELAX", "MALIN", "LÂCHE", "TIMIDE", "PRESSÉ", "SÉRIEUX", "JOVIAL", "NAÏF",
			"MODESTE", "DOUX", "DISCRET", "PUDIQUE", "FOUFOU", "CALME", "GENTIL", "MALPOLI", "PRUDENT", "BIZARRE"} -- French
	elseif emu.memory.cart0:read8(0xAF) == 0x49 then
		List = {"ARDITA", "SCHIVA", "AUDACE", "DECISA", "BIRBONA",
			"SICURA", "DOCILE", "PLACIDA", "SCALTRA", "FIACCA", "TIMIDA", "LESTA", "SERIA", "ALLEGRA", "INGENUA",
			"MODESTA", "MITE", "QUIETA", "RITROSA", "ARDENTE", "CALMA", "GENTILE", "VIVACE", "CAUTA", "FURBA"} -- Italian
	elseif emu.memory.cart0:read8(0xAF) == 0x53 then
		List = {"FUERTE", "HURAÑA", "AUDAZ", "FIRME", "PÍCARA",
			"OSADA", "DÓCIL", "PLÁCIDA", "AGITADA", "FLOJA", "MIEDOSA", "ACTIVA", "SERIA", "ALEGRE", "INGENUA",
			"MODESTA", "AFABLE", "MANSA", "TÍMIDA", "ALOCADA", "SERENA", "AMABLE", "GROSERA", "CAUTA", "RARA"} -- Spanish
	else
		List = {"HARDY", "LONELY", "BRAVE", "ADAMANT", "NAUGHTY",
			"BOLD", "DOCILE", "RELAXED", "IMPISH", "LAX", "TIMID", "HASTY", "SERIOUS", "JOLLY", "NAIVE",
			"MODEST", "MILD", "QUIET", "BASHFUL", "RASH", "CALM", "GENTLE", "SASSY", "CAREFUL", "QUIRKY"} -- English
	end
	if pos == neg then temp[pos+1]="+/-" else temp[pos+1], temp[neg+1] = "+10%", "-10%" end
	local nature = {List[nat+1], "", temp[1], temp[2], temp[4], temp[5], temp[3]}
	return nature -- nature = {Type, AltStats..}
end

-- Hidden Power
function Game.getHiPo(game, gen)
	local temp = {gen[1], gen[2], gen[3], gen[6], gen[4], gen[5]}
	local sum = {0, 0}
	for i,v in ipairs(temp) do
		if v%4 == 0 or v%4 == 1 then val=0 else val=2^(i-1) end
		sum[1] = sum[1] + (v%2)*(2^(i-1))
		sum[2] = sum[2] + val
	end
	local hipo = {game:_readTypeList(math.floor(sum[1]*15/63)), math.floor((sum[2]*40/63)+30)}
	return hipo -- hipo = {Type, Power}
end

-- List of types
function Game._readTypeList(game, ti)
	if emu.memory.cart0:read8(0xAF) == 0x44 then
		List = {"KAMPF", "FLUG", "GIFT", "BODEN", "GESTEIN", "KÄFER", "GEIST", "STAHL",
			"FEUER", "WASSER", "PFLANZE", "ELEKTRO", "PSYCHO", "EIS", "DRACHE", "UNLICHT"} -- Deutsch
	elseif emu.memory.cart0:read8(0xAF) == 0x46 then
		List = {"COMBAT", "VOL", "POISON", "SOL", "ROCHE", "INSECTE", "SPECTRE", "ACIER",
			"FEU", "EAU", "PLANTE", "ÉLECTRIK", "PSY", "GLACE", "DRAGON", "TÉNÈBRES"} -- French
	elseif emu.memory.cart0:read8(0xAF) == 0x49 then
		List = {"LOTTA", "VOLANTE", "VELENO", "TERRA", "ROCCIA", "COLEOTTERO", "SPETTRO", "ACCIAIO",
			"FUOCO", "ACQUA", "ERBA", "ELETTRO", "PSICO", "GHIACCIO", "DRAGO", "BUIO"} -- Italian
	elseif emu.memory.cart0:read8(0xAF) == 0x53 then
		List = {"LUCHA", "VOLADOR", "VENENO", "TIERRA", "ROCA", "BICHO", "FANTASMA", "ACERO",
			"FUEGO", "AGUA", "PLANTA", "ELECTRICO", "PSIQUICO", "HIELO", "DRAGON", "SINIESTRO"} -- Spanish
	else
		List = {"FIGHTING", "FLYING", "POISON", "GROUND", "ROCK", "BUG", "GHOST", "STEEL",
			"FIRE", "WATER", "GRASS", "ELECTRIC", "PSYCHIC", "ICE", "DRAGON", "DARK"} -- English
	end
	local type = List[ti+1]
	return type
end

Game._charmap = { [0]=
	" ", "À", "Á", "Â", "Ç", "È", "É", "Ê", "Ë", "Ì", "こ", "Î", "Ï", "Ò", "Ó", "Ô",
	"Œ", "Ù", "Ú", "Û", "Ñ", "ß", "à", "á", "ね", "ç", "è", "é", "ê", "ë", "ì", "ま",
	"î", "ï", "ò", "ó", "ô", "œ", "ù", "ú", "û", "ñ", "º", "ª", "�", "&", "+", "あ",
	"ぃ", "ぅ", "ぇ", "ぉ", "v", "=", "ょ", "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ",
	"ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
	"っ", "¿", "¡", "P\u{200d}k", "M\u{200d}n", "P\u{200d}o", "K\u{200d}é", "�", "�", "�", "Í", "%", "(", ")", "セ", "ソ",
	"タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "â", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "í",
	"ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "⬆", "⬇", "⬅", "➡", "ヲ", "ン", "ァ",
	"ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ",
	"ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ", "パ", "ピ", "プ", "ペ", "ポ",
	"ッ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "!", "?", ".", "-", "・",
	"…", "“", "”", "‘", "’", "♂", "♀", "$", ",", "×", "/", "A", "B", "C", "D", "E",
	"F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
	"V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "▶",
	":", "Ä", "Ö", "Ü", "ä", "ö", "ü", "⬆", "⬇", "⬅", "�", "�", "�", "�", "�", ""
}

Game._charmapJP = { [0]=
	" ", "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ",
	"た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま",
	"み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "を", "ん", "あ",
	"ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ",
	"ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
	"っ", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ",
	"タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ",
	"ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ヲ", "ン", "ァ",
	"ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ",
	"ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ", "パ", "ピ", "プ", "ペ", "ポ",
	"ッ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "!", "?", "。", "-", "・",
	"…", "『", "』", "「", "」", "♂", "♀", "円", ".", "×", "/", "A", "B", "C", "D", "E",
	"F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
	"V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "▶",
	":", "Ä", "Ö", "Ü", "ä", "ö", "ü", "⬆", "⬇", "⬅", "�", "�", "�", "�", "�", ""
}

-- Eval stats
function Game.readBoxMon(game, address)
	local mon = {}
	--mon.status = emu:read32(address + 80)
	mon.level = emu:read8(address + 84)
	--mon.mail = emu:read32(address + 85)
	--mon.hp = emu:read16(address + 86)
	
	mon.STs = {
		emu:read16(address + 88),
		emu:read16(address + 90),
		emu:read16(address + 92),
		emu:read16(address + 96),
		emu:read16(address + 98),
		emu:read16(address + 94)
	}
	
	mon.personality = emu:read32(address + 0)
	mon.otId = emu:read32(address + 4)
	mon.nickname = game:toString(emu:readRange(address + 8, 10))
	--mon.language = emu:read8(address + 18)
	mon.nature = mon.personality % 25
	--mon.otName = game:toString(emu:readRange(address + 20, 10))
	--mon.markings = emu:read8(address + 27)
	
	local flags = emu:read8(address + 19)
	--mon.isBadEgg = flags & 1
	--mon.hasSpecies = (flags >> 1) & 1
	--mon.isEgg = (flags >> 2) & 1
	
	local key = mon.otId ~ mon.personality
	mon.shi = math.floor(key/0x10000) ~ (key % 0x10000)
	local substructSelector = {
		[ 0] = {0, 1, 2, 3},
		[ 1] = {0, 1, 3, 2},
		[ 2] = {0, 2, 1, 3},
		[ 3] = {0, 3, 1, 2},
		[ 4] = {0, 2, 3, 1},
		[ 5] = {0, 3, 2, 1},
		[ 6] = {1, 0, 2, 3},
		[ 7] = {1, 0, 3, 2},
		[ 8] = {2, 0, 1, 3},
		[ 9] = {3, 0, 1, 2},
		[10] = {2, 0, 3, 1},
		[11] = {3, 0, 2, 1},
		[12] = {1, 2, 0, 3},
		[13] = {1, 3, 0, 2},
		[14] = {2, 1, 0, 3},
		[15] = {3, 1, 0, 2},
		[16] = {2, 3, 0, 1},
		[17] = {3, 2, 0, 1},
		[18] = {1, 2, 3, 0},
		[19] = {1, 3, 2, 0},
		[20] = {2, 1, 3, 0},
		[21] = {3, 1, 2, 0},
		[22] = {2, 3, 1, 0},
		[23] = {3, 2, 1, 0},
	}
	
	local pSel = substructSelector[mon.personality % 24]
	local ss0 = {}
	local ss1 = {}
	local ss2 = {}
	local ss3 = {}
	
	for i = 0, 2 do
		ss0[i] = emu:read32(address + 32 + pSel[1] * 12 + i * 4) ~ key
		ss1[i] = emu:read32(address + 32 + pSel[2] * 12 + i * 4) ~ key
		ss2[i] = emu:read32(address + 32 + pSel[3] * 12 + i * 4) ~ key
		ss3[i] = emu:read32(address + 32 + pSel[4] * 12 + i * 4) ~ key
	end
	
	mon.species = ss0[0] & 0xFFFF
	--mon.heldItem = ss0[0] >> 16
	mon.experience = ss0[1]
	--mon.ppBonuses = ss0[2] & 0xFF
	--mon.friendship = (ss0[2] >> 8) & 0xFF
	
	mon.moves = {
		ss1[0] & 0xFFFF,
		ss1[0] >> 16,
		ss1[1] & 0xFFFF,
		ss1[1] >> 16
	}
	
	mon.pp = {
		ss1[2] & 0xFF,
		(ss1[2] >> 8) & 0xFF,
		(ss1[2] >> 16) & 0xFF,
		ss1[2] >> 24
	}
	
	mon.EVs = {
		ss2[0] & 0xFF,
		(ss2[0] >> 8) & 0xFF,
		(ss2[0] >> 16) & 0xFF,
		ss2[1] & 0xFF,
		(ss2[1] >> 8) & 0xFF,
		ss2[0] >> 24
	}
	
	--mon.cool = (ss2[1] >> 16) & 0xFF
	--mon.beauty = ss2[1] >> 24
	--mon.cute = ss2[2] & 0xFF
	--mon.smart = (ss2[2] >> 8) & 0xFF
	--mon.tough = (ss2[2] >> 16) & 0xFF
	--mon.sheen = ss2[2] >> 24
	
	--mon.pokerus = ss3[0] & 0xFF
	--mon.metLocation = (ss3[0] >> 8) & 0xFF
	
	flags = ss3[0] >> 16
	--mon.metLevel = flags & 0x7F
	--mon.metGame = (flags >> 7) & 0xF
	--mon.pokeball = (flags >> 11) & 0xF
	--mon.otGender = (flags >> 15) & 0x1
	
	flags = ss3[1]
	mon.IVs = {
		flags & 0x1F,
		(flags >> 5) & 0x1F,
		(flags >> 10) & 0x1F,
		(flags >> 20) & 0x1F,
		(flags >> 25) & 0x1F,
		(flags >> 15) & 0x1F,
	}
	
	-- Bit 30 is another "isEgg" bit
	--mon.altAbility = (flags >> 31) & 1
	
	--flags = ss3[2]
	--mon.coolRibbon = flags & 7
	--mon.beautyRibbon = (flags >> 3) & 7
	--mon.cuteRibbon = (flags >> 6) & 7
	--mon.smartRibbon = (flags >> 9) & 7
	--mon.toughRibbon = (flags >> 12) & 7
	--mon.championRibbon = (flags >> 15) & 1
	--mon.winningRibbon = (flags >> 16) & 1
	--mon.victoryRibbon = (flags >> 17) & 1
	--mon.artistRibbon = (flags >> 18) & 1
	--mon.effortRibbon = (flags >> 19) & 1
	--mon.marineRibbon = (flags >> 20) & 1
	--mon.landRibbon = (flags >> 21) & 1
	--mon.skyRibbon = (flags >> 22) & 1
	--mon.countryRibbon = (flags >> 23) & 1
	--mon.nationalRibbon = (flags >> 24) & 1
	--mon.earthRibbon = (flags >> 25) & 1
	--mon.worldRibbon = (flags >> 26) & 1
	--mon.eventLegal = (flags >> 27) & 0x1F
	return mon
end

-- English
local gameRubyEn = Game:new{
	name="Ruby (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1F716C,
	_enemy=0x030045C0,
	_seed=0x03004818,
	_seed0=0x2020000,
}

local gameRubyEnR1 = gameRubyEn:new{
	name="Ruby (USA) (Rev 1)",
	_speciesNameTable=0x1F7184,
}

local gameSapphireEn = Game:new{
	name="Sapphire (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1F70fC,
	_enemy=0x30045C0,
	_seed=0x03004818,
	_seed0=0x2020000,
}

local gameSapphireEnR1 = gameSapphireEn:new{
	name="Sapphire (USA) (Rev 1)",
	_speciesNameTable=0x1F7114,
}

local gameEmeraldEn = Game:new{
	name="Emerald (USA)",
	_party=0x20244EC,
	_partyCount=0x20244E9,
	_speciesNameTable=0x3185C8,
	_enemy=0x2024744,
	_seed=0x03005D80,
	_seed0=0x2020000,
}

local gameFireRedEn = Game:new{
	name="FireRed (USA)",
	_party=0x2024284,
	_partyCount=0x2024029,
	_speciesNameTable=0x245EE0,
	_enemy=0x0202402C,
	_seed=0x03004F50,
	_seed0=0x2020000,
}

local gameFireRedEnR1 = gameFireRedEn:new{
	name="FireRed (USA) (Rev 1)",
	_speciesNameTable=0x245F50,
}

local gameLeafGreenEn = Game:new{
	name="LeafGreen (USA)",
	_party=0x2024284,
	_partyCount=0x2024029,
	_speciesNameTable=0x245EBC,
	_enemy=0x0202402C,
	_seed=0x03004F50,
	_seed0=0x2020000,
}

local gameLeafGreenEnR1 = gameLeafGreenEn:new{
	name="LeafGreen (USA) (Rev 1)",
}

-- Spanish
local gameRubySp = Game:new{
	name="Rubí (Spain)",
	_party=0x3004370,
	_partyCount=0x3004360,
	_speciesNameTable=0x1FBE8C,
	_enemy=0x030045D0,
	_seed=0x03004828,
	_seed0=0x2020000,
}

local gameSapphireSp = Game:new{
	name="Safiro (Spain)",
	_party=0x3004370,
	_partyCount=0x3004360,
	_speciesNameTable=0x1FBE1C,
	_enemy=0x030045D0,
	_seed=0x03004828,
	_seed0=0x2020000,
}

local gameEmeraldSp = gameEmeraldEn:new{
	name="Esmeralda (Spain)",
	_speciesNameTable=0x31E82C,
}

local gameFireRedSp = gameFireRedEn:new{
	name="RojoFuego (Spain)",
	_speciesNameTable=0x24164C,
}

local gameLeafGreenSp = gameLeafGreenEn:new{
	name="VerdeHoja (Spain)",
	_speciesNameTable=0x241628,
}

-- Deutsch
local gameRubyDe = gameRubySp:new{
	name="Rubin (Germany)",
	_speciesNameTable=0x2040E8,
}

local gameSapphireDe = gameSapphireSp:new{
	name="Saphir (Germany)",
	_speciesNameTable=0x20407C,
}

local gameEmeraldDe = gameEmeraldEn:new{
	name="Smaragd (Germany)",
	_speciesNameTable=0x32CF38,
}

local gameFireRedDe = gameFireRedEn:new{
	name="Feuerrote (Germany)",
	_speciesNameTable=0x245DB0,
}

local gameLeafGreenDe = gameLeafGreenEn:new{
	name="Blattgruene (Germany)",
	_speciesNameTable=0x245D8C,
}

-- French
local gameRubyFr = gameRubySp:new{
	name="Rubis (France)",
	_speciesNameTable=0x1FF574,
}

local gameSapphireFr = gameSapphireSp:new{
	name="Saphir (France)",
	_speciesNameTable=0x1FF504,
}

local gameEmeraldFr = gameEmeraldEn:new{
	name="Emeraude (France)",
	_speciesNameTable=0x3200F8,
}

local gameFireRedFr = gameFireRedEn:new{
	name="RougeFeu (France)",
	_speciesNameTable=0x2402EC,
}

local gameLeafGreenFr = gameLeafGreenEn:new{
	name="VertFeuille (France)",
	_speciesNameTable=0x2402C8,
}

-- Italian
local gameRubyIt = gameRubySp:new{
	name="Rubino (Italy)",
	_speciesNameTable=0x1F8E08,
}

local gameSapphireIt = gameSapphireSp:new{
	name="Zaffiro (Italy)",
	_speciesNameTable=0x1F8D98,
}

local gameEmeraldIt = gameEmeraldEn:new{
	name="Smeraldo (Italy)",
	_speciesNameTable=0x317F8C,
}

local gameFireRedIt = gameFireRedEn:new{
	name="RossoFuoco (Italy)",
	_speciesNameTable=0x23EF84,
}

local gameLeafGreenIt = gameLeafGreenEn:new{
	name="VerdeFoglia (Italy)",
	_speciesNameTable=0x23EF60,
}

-- Japanese
local gameRubyJp = Game:new{
	name="Ruby (Japan)",
	_party=0x02024190,
	_partyCount=0x0202418D,
	_speciesNameTable=0x0202370C,--X
	_enemy=0x020243E8,
	_seed=0x03005AE0,
	_seed0=0x2020000,
}

local gameSapphireJp = Game:new{
	name="Sapphire (Japan)",
	_party=0x02024190,
	_partyCount=0x0202418D,
	_speciesNameTable=0x0202370C,--X
	_enemy=0x020243E8,
	_seed=0x03005AE0,
	_seed0=0x2020000,
}

local gameEmeraldJp = Game:new{
	name="Emerald (Japan)",
	_party=0x02024190,
	_partyCount=0x0202418D,
	_speciesNameTable=0x0202370C,--X
	_enemy=0x020243E8,
	_seed=0x03005AE0,
	_seed0=0x2020000,
}

local gameFireRedJp = Game:new{
	name="FireRed (Japan)",
	_party=0x020241E4,
	_partyCount=0x02023F89,
	_speciesNameTable=0x02023528,--X
	_enemy=0x02023F8C,
	_seed=0x03005040,
	_seed0=0x2020000,
}

local gameLeafGreenJp = Game:new{
	name="LeafGreen (Japan)",
	_party=0x020241E4,
	_partyCount=0x02023F89,
	_speciesNameTable=0x02023528,--X
	_enemy=0x02023F8C,
	_seed=0x03005040,
	_seed0=0x2020000,
}

-- Codes of games
gameCodes = {
	["AGB-AXVE"]=gameRubyEn,
	["AGB-AXPE"]=gameSapphireEn,
	["AGB-BPEE"]=gameEmeraldEn,
	["AGB-BPRE"]=gameFireRedEn,
	["AGB-BPGE"]=gameLeafGreenEn,
	
	["AGB-AXVD"]=gameRubyDe, -- Deutsch
	["AGB-AXPD"]=gameSapphireDe, -- Deutsch
	["AGB-BPED"]=gameEmeraldDe, -- Deutsch
	["AGB-BPRD"]=gameFireRedDe, -- Deutsch
	["AGB-BPGD"]=gameLeafGreenDe, -- Deutsch
	
	["AGB-AXVF"]=gameRubyFr, -- French
	["AGB-AXPF"]=gameSapphireFr, -- French
	["AGB-BPEF"]=gameEmeraldFr, -- French
	["AGB-BPRF"]=gameFireRedFr, -- French
	["AGB-BPGF"]=gameLeafGreenFr, -- French
	
	["AGB-AXVI"]=gameRubyIt, -- Italian
	["AGB-AXPI"]=gameSapphireIt, -- Italian
	["AGB-BPEI"]=gameEmeraldIt, -- Italian
	["AGB-BPRI"]=gameFireRedIt, -- Italian
	["AGB-BPGI"]=gameLeafGreenIt, -- Italian
	
	["AGB-AXVS"]=gameRubySp, -- Spanish
	["AGB-AXPS"]=gameSapphireSp, -- Spanish
	["AGB-BPES"]=gameEmeraldSp, -- Spanish
	["AGB-BPRS"]=gameFireRedSp, -- Spanish
	["AGB-BPGS"]=gameLeafGreenSp, -- Spanish
	
	["AGB-AXVJ"]=gameRubyJp, -- Japanese
	["AGB-AXPJ"]=gameSapphireJp, -- Japanese
	["AGB-BPEJ"]=gameEmeraldJp, -- Japanese
	["AGB-BPRJ"]=gameFireRedJp, -- Japanese
	["AGB-BPGJ"]=gameLeafGreenJp, -- Japanese
}

-- These versions have slight differences and/or cannot be uniquely
-- identified by their in-header game codes, so fall back on a CRC32
gameCrc32 = {
	[0x84ee4776] = gameFireRedEnR1,
	[0xdaffecec] = gameLeafGreenEnR1,
	[0x61641576] = gameRubyEnR1, -- Rev 1
	[0xaeac73e6] = gameRubyEnR1, -- Rev 2
	[0xbafedae5] = gameSapphireEnR1, -- Rev 1
	[0x9cc4410e] = gameSapphireEnR1, -- Rev 2
}

-- Pokemon Status
function printPokeStatus(game, buffer, pkm)
	buffer:clear()
	local mon = game:readBoxMon(pkm)
	local traID = {mon.otId%0x10000, math.floor(mon.otId/0x10000)}
	local bst = {0, 0}
	if mon.shi < 8 then shiny = "*SHINY*" else shiny = "" end
	label = {"HP", "Attack", "Defense", "SpAttack", "SpDefense", "Speed"}
	buffer:print(string.format("Initial seed: %4X          TID: %-5i  SID: %-5i\n", emu:read16(game._seed0), traID[1], traID[2]))
	buffer:print(string.format("                                                  \n\n"))
	buffer:print(string.format("     ----------%s----------     \n\n", options[sel][1]))
	buffer:print(string.format("%10s / %-10s Lv %-3i -%s-\n", mon.nickname, game:getSpeciesName(mon.species), mon.level, game:getNature(mon.nature)[1]))
	buffer:print(string.format("PID: %8X  %s  HPower: %s (%i)\n\n", mon.personality, shiny, game:getHiPo(mon.IVs)[1], game:getHiPo(mon.IVs)[2]))
	buffer:print("             Stat    IV    EV\n------------------------------------\n")
	for i = 1, 6 do
		buffer:print(string.format("%-9s    %4i    %2i   %3i   %-4s\n", label[i], mon.STs[i], mon.IVs[i], mon.EVs[i], game:getNature(mon.nature)[i+1]))
		bst[1], bst[2] = bst[1] + mon.STs[i], bst[2] + mon.EVs[i]
	end
	buffer:print(string.format("------------------------------------\n             %4i         %3i\n\n", bst[1], bst[2]))
	buffer:print(string.format("Next Pokemon: START + RIGHT\nPrev Pokemon: START + LEFT\n"))
end

-- Initial seed: AB12          TID: 1234_  SID: 12345
-- Current seed: 1234ABCD      Advances: ___________0
-- 
--      ----------POKEMON 1----------     
--
-- __NICKNAME / POKEMON___ Lv 1__ -ALOCADA-
-- PID: 1234ABCD  *SHINY*  HPower: SINIESTRO (30)
--
--              Stat    IV    EV
-- ------------------------------------              (50)
-- HP_______    _100    31   252   ____
-- Attack___    _100    31   252   +10%
-- Defense__    _100    31   __0   -10%
-- SpAttack_    _100    31   __0   +/-
-- SpDefence    _100    31   __0   ____
-- Speed____    _100    31   __0   ____
-- ------------------------------------
--              _600         504
-- 
-- Next Pokemon: START + RIGHT
-- Prev Pokemon: START + LEFT

function detectGame()
	local checksum = 0
	for i, v in ipairs({emu:checksum(C.CHECKSUM.CRC32):byte(1, 4)}) do
		checksum = checksum * 256 + v
	end
	game = gameCrc32[checksum]
	if not game then
		game = gameCodes[emu:getGameCode()]
	end

	if not game then
		console:error(string.format("Unknown game! Code: %8s", emu:getGameCode()))
	else
		console:log(string.format("\nFound game: %s [%8s]\n", game.name, emu:getGameCode()))
		if not statsBuffer then
			statsBuffer = console:createBuffer("Stats")
		else
			statsBuffer:clear()
		end
		frame = 0
		options = {
			[0] = {"WILD POKEMON", game._enemy},
			[1] = {"POKEMON 1", game._party},
			[2] = {"POKEMON 2", game._party + 100},
			[3] = {"POKEMON 3", game._party + 200},
			[4] = {"POKEMON 4", game._party + 300},
			[5] = {"POKEMON 5", game._party + 400},
			[6] = {"POKEMON 6", game._party + 500},
		}
		sel = 1
		lastKey = nil
	end
end

function scanKeys()
	local selKey = emu:getKeys()
	local party = emu:read8(game._partyCount)
	if selKey ~= lastKey then
		lastKey = selKey
		if lastKey == 0x18 then
			sel = sel + 1
			if sel==(party+1) then sel=0 end
		elseif lastKey == 0x28 then
			sel = sel - 1
			if sel==-1 then sel=party end
		end
	end
end

local JUMP_DATA = {
 {0x41C64E6D, 0x6073}, {0xC2A29A69, 0xE97E7B6A}, {0xEE067F11, 0x31B0DDE4}, {0xCFDDDF21, 0x67DBB608},
 {0x5F748241, 0xCBA72510}, {0x8B2E1481, 0x1D29AE20}, {0x76006901, 0xBA84EC40}, {0x1711D201, 0x79F01880},
 {0xBE67A401, 0x8793100}, {0xDDDF4801, 0x6B566200}, {0x3FFE9001, 0x803CC400}, {0x90FD2001, 0xA6B98800},
 {0x65FA4001, 0xE6731000}, {0xDBF48001, 0x30E62000}, {0xF7E90001, 0xF1CC4000}, {0xEFD20001, 0x23988000},
 {0xDFA40001, 0x47310000}, {0xBF480001, 0x8E620000}, {0x7E900001, 0x1CC40000}, {0xFD200001, 0x39880000},
 {0xFA400001, 0x73100000}, {0xF4800001, 0xE6200000}, {0xE9000001, 0xCC400000}, {0xD2000001, 0x98800000},
 {0xA4000001, 0x31000000}, {0x48000001, 0x62000000}, {0x90000001, 0xC4000000}, {0x20000001, 0x88000000},
 {0x40000001, 0x10000000}, {0x80000001, 0x20000000}, {0x1, 0x40000000}, {0x1, 0x80000000}}

function LCRNG(s, mul, sum)
 local a = (mul >> 16) * (s % 0x10000) + (s >> 16) * (mul % 0x10000)
 local b = (mul % 0x10000) * (s % 0x10000) + (a % 0x10000) * 0x10000 + sum

 return b % 0x100000000
end

function LCRNGDistance(state0, state1)
 local mask = 1
 local dist = 0

 if state0 ~= state1 then
  for _, data in ipairs(JUMP_DATA) do
   local mult, add = table.unpack(data)

   if state0 == state1 then
    break
   end

   if ((state0 ~ state1) & mask) ~= 0 then
    state0 = LCRNG(state0, mult, add)
    dist = dist + mask
   end

   mask = mask << 1
  end

  tempCurrentSeed = state1
 end

 return dist > 999 and dist - 0x100000000 or dist
end

local advances, tempCurrentSeed, tempInitialSeed, initialSeed = 0, 0, 0

function getAdvances()
 local currentSeed = emu:read32(game._seed)

 if emu:currentFrame() < 8 and currentSeed < 0x10000 then
  initialSeed = currentSeed
 end

 if tempInitialSeed ~= initialSeed then
  tempInitialSeed = initialSeed
  tempCurrentSeed = initialSeed
  advances = 0
 end

 if currentSeed ~= tempCurrentSeed then
  advances = advances + LCRNGDistance(tempCurrentSeed, currentSeed)
  tempCurrentSeed = currentSeed
 end

 return advances
end

function updateBuffer()
	if not game or not statsBuffer then
		return
	end
	
	current = options[sel][2]
	
	if prev==nil or prev~=emu:read32(current) or prevExp~=game:readBoxMon(current).experience or frame < 5 then
		printPokeStatus(game, statsBuffer, current)
		prev = emu:read32(current)
		prevExp = game:readBoxMon(current).experience
		frame = frame + 1
		if frame == 6 then frame = 0 end
	end
	
	statsBuffer:moveCursor(0,1)
	statsBuffer:print(string.format("Current seed: %8X      Advances: %12i\n\n", emu:read32(game._seed), getAdvances()))
end

callbacks:add("keysRead", scanKeys)
callbacks:add("frame", updateBuffer)
callbacks:add("reset", detectGame)
callbacks:add("start", detectGame)

if emu then
	detectGame()
end
