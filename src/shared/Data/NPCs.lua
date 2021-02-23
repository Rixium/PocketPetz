local NPCs = {};
local Templates = {};


Templates.Woman = {
    Head = 746767604,
    Torso = 86499666,
    LeftArm = 86499716,
    RightArm = 86499698,
    LeftLeg = 86499753,
    RightLeg = 86499793
};

Templates.Man = {
    LeftArm = 86500054,
    RightArm = 86500036,
    LeftLeg = 86500064,
    RightLeg = 86500078,
    Torso = 86500008,
    Head = 616387160
};

NPCs.Grey = {
    Name = "Grey",
    Title = "Legend",
    Dialog = {
        "Yo.",
        "I'm Grey.",
        "CoolPets are my game.",
        "They make PixiePets weak at the knees.",
        "But, they really struggle around the BrutePets.",
        "Meh, your choice.."
    },
    SeeAnimation = 507770453,
    ShirtId = 5774384277,
    PantsId = 6335710383,
    SkinColor = Color3.fromRGB(234, 184, 146),
    Body = Templates.Man,
    Hair = 4965584454,
    Face = 20418658
};
NPCs.Fawn = {
    Name = "Fawn",
    Title = "Legend",
    Dialog = {
        "Hey, the names Fawn.",
        "BrutePets are absolute beasts!",
        "They can grow to be some of the biggest in the world.",
        "They're not great around PixiePets, but...",
        "They'll really trash the CoolPets!"
    },
    SeeAnimation = 507770677,
    ShirtId = 6007176062,
    PantsId = 382537569,
    SkinColor = Color3.fromRGB(175, 148, 131),
    Body = Templates.Woman,
    Hair = 456225312,
    Face = 22877700
};
NPCs.Melody = {
    Name = "Melody",
    Title = "Legend",
    Dialog = {
        "Heya!",
        "You can call me Melody!",
        "PixiePets are awesome, cute singing pets!",
        "They'll dazzle even the biggest pets with their voices!",
        "But, they can't resist a CoolPet, *sqweee*!"
    },
    SeeAnimation = 507770239,
    ShirtId = 1110657393,
    PantsId = 4454568025,
    SkinColor = Color3.fromRGB(86, 66, 54),
    Body = Templates.Woman,
    Hair = 4876397180,
    Face = 12145366
};

return NPCs;