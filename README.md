# PocketPetz
Welcome, Welcome!

You are now a proud of Developer of PocketPetz.
It's gonna be tough getting started, as there's lots to learn, but we've got these docs to help you through.

## Developing the Game

### Getting Started

- Clone this repo locally
- Install [ROBLOX Studio](https://www.roblox.com/create) and get Developer permissions from iRixium
- Install [Visual Studio Code](https://code.visualstudio.com/download)
- Install the Rojo plugin for Visual Studio Code, from the [Marketplace](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
- Open the workspace in Visual Studio Code
- Start the Rojo server using Ctrl + Shift + P, and searching for 'Start Server' in the pop-up
- Once started, open the Roblox Studio project, and go to Plugins > Rojo > Connect

You should now be able to develop any code using Visual Studio Code, that will be automatically synced over to the Roblox level.

The best way to develop would be to create scripts and assets in a separate level, and bring them over to PocketPetz once you're done. It will help avoid any conflicts with other Developers!

### Working with ROJO

There are some good documentation offered by ROJO, but you can see how it is used by the current project structure.
If you need clarification, don't hesitate to ask the team!

## Administration

As a Developer, you should have access to the top-tier of PocketPetz administration.
You should have been added as an admin by now, but if not, check with the team!

## Adding New Monsters
How exciting! You want to add a new monster to the game. Well, it's a bit of a pain in the ass, but here we go.

### Create the Model
In the 'Pets' world, copy the template of other pets there, and drag in your new model.
Place it on the plinth, and upload it to YetiFace.

* The plinth is required, so we get the perfect thumbnail.

We also need some animations defined for each pet, and uploaded to the store:
- Attack
- Hurt
- Death
- Walk

The animation needs to be in the Animations folder of each pet, so that our scripts can access them.

### In the Real World
Now we have the model defined, we can head over the Pocket Pets.

#### ItemList.lua
All new creatures (pets too!), need to be defined in the ItemList, it's a bit of a pain, but it's the way. (We were learning a lot when we first started making this game, and we've got some bad design decisions because of it.)
Open ItemList.lua, and similar to the others, just define the structure exactly the same:

        - ItemId = 3 < This matches the current index of the table, so just increment the last by 1, and that's it!
        - ItemType = "Pet" < It probably needs to be set as "Pet"
        - Rarity = "Common" < Up to you :)
        - Name = "Pebbles" < The display name of the pet.
        - Description = "I wonder what's inside?" < This shows when viewing the pet in the inventory
        - ModelId = 6492034287 < This is the model Id for what you uploaded to the shared models.
        - ThumbnailId = 6488394187 < DEPRECATED, Why is this still here? Dunno.
        - ExperienceToLevel = 10 < Some pets may have drastically different experience required to level, set it here.
        - LevelToEvolve = 2 < At what point will the pet evolve in to the next one below.
        - EvolvesTo = 6 < If it evolves, which ItemId does it evolve to?

#### CreatureService.lua
Since creatures are a little different from pets (They're basically some extra data that relates to what they drop), we also need to define the creature data, for all pets that intend to be attacked.

    [1] = { < Increment this for new creatures
        ItemId = 13 < The ItemId it is related to! We need this to get some data, such as base health..
        Drops = { < A table of drops
            [14] = {
                ItemId = 14 < What the drop is, (make sure the index and itemId matches for now)
                Chance = 0.01 < The percentage chance of this item dropping
            },
            [15] = {
                ItemId = 15 < See above
                Chance = 0.001 < See above
            }
        }
    }

#### If it's a new creature
There is a bunch of stuff we need for this. First, ideally, you already have a zone where you're gonna place your mobs.
If so, add them there, if not, then start worrying, and make one. :)

Once you've dragged the first one in, you need to make sure that the Parent model has the 'Creature' tag, and that the body of the creature has the 'Attackable' tag.
This is so that:
    A) Our creature can be set-up on server start, with all required variables and properties.
    B) If it's not attackable, then we can't actually attack it, sadface.

With that out the way, we can now define the data we need: