class ZedSkinByMap extends Mutator
    config(ZedSkinByMap);


// default skin type by default
var config string defaultSkinType;
// skin type - map array
struct sMapZedType
{
    var string Map;
    var string ZedSkin;
};
var config array<sMapZedType> SkinMapList;


// yea, ideal place to start our magic
function MatchStarting()
{
    local string mapName, ZedSkin;
    local int i, n;
    local KFGameType kf;

    kf = KFGameType(level.game);
    // shut down if we can't find KFGameType!
    // since most of our code works with it
    if (kf == none)
    {
        log(">>> ZedSkinByMap - PostBeginPlay(): KFGameType not found. TERMINATING!");
        Destroy();
        return;
    }

    // get map name with prefix
    mapName = caps(kf.getCurrentMapName(level));
    log(">>> ZedSkinByMap - SetZedType(): mapName is " $ mapName);

    // get season type for current map
    for (i = 0; i < SkinMapList.Length; i++)
    {
        if (mapName == caps(SkinMapList[i].Map))
        {
            ZedSkin = caps(SkinMapList[i].ZedSkin);
            // fancy logs everywhere!
            log(">>> ZedSkinByMap - SetZedType(): ZedSkin is " $ ZedSkin);
            break;
        }
    }

    // if not found, use default value
    if (ZedSkin == "")
        ZedSkin = defaultSkinType;

    // oh god, I have to do this because someone thought
    // random zed skins on each map switch is a fun idea
    n = getSeasonNum(ZedSkin);

    if (n == 0)
    {
        kf.SpecialEventType = ET_SummerSideshow;
        log(">>> ZedSkinByMap - SetZedType(): changed Zed Type to ET_SummerSideshow.");
    }
    else if (n == 1)
    {
        kf.SpecialEventType = ET_HillbillyHorror;
        log(">>> ZedSkinByMap - SetZedType(): changed Zed Type to ET_HillbillyHorror.");
    }
    else if (n == 2)
    {
        kf.SpecialEventType = ET_TwistedChristmas;
        log(">>> ZedSkinByMap - SetZedType(): changed Zed Type to ET_TwistedChristmas.");
    }
    else if (n == 3)
    {
        kf.SpecialEventType = ET_None;
        log(">>> ZedSkinByMap - SetZedType(): Zed Type set to default");
    }

    // change monster collection
    kf.MonsterCollection = kf.SpecialEventMonsterCollections[kf.SpecialEventType];
    // redefine zeds and special squads according to new SpecialEventType
    kf.LoadUpMonsterList();
    kf.PrepareSpecialSquads();

    // all work is done, terminate
    Destroy();
}


// don't beat me, pls
final private function int getSeasonNum(string s)
{
    if (s == "RANDOM" || s == "RND")
        return rand(4);
    else if (s == "CIRCUS" || s == "C")
        return 0;
    else if (s == "HALLOWEEN" || s == "H")
        return 1;
    else if (s == "XMAS" || s == "X")
        return 2;
    else
        return 3;
}


defaultproperties
{
    GroupName="KF-ZedSkinByMap"
    FriendlyName="Zed Skin By Map"
    Description="Choose specific zed skins for map"
}