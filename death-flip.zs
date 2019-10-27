class df_EventHandler : EventHandler
{

// public: // EventHandler /////////////////////////////////////////////////////

  override
  void OnRegister()
  {
    blacklist = new("df_StringSet").init();
  }

  override
  void WorldThingDied(WorldEvent event)
  {
    let thing = event.thing;
    if (thing == NULL) { return; }

    if (blacklist.contains(thing.GetClassName())) { return; }

    bool flipped = df_alternate
                 ? (isPrevFlipped = !isPrevFlipped)
                 : random(0, 1);

    if (flipped)
    {
      flip(thing);
      thing.GiveInventory("df_MirroredFlag", 1);
    }
  }

  override
  void WorldThingRevived(WorldEvent event)
  {
    let thing = event.thing;
    if (thing == NULL) { return; }

    if (blacklist.contains(thing.GetClassName())) { return; }

    thing.GiveInventory("df_Unflipper", 1);
  }

// public: /////////////////////////////////////////////////////////////////////

  static
  void flip(Actor thing)
  {
    thing.A_SetScale(-thing.Scale.X, thing.Scale.Y);
  }

// private: /////////////////////////////////////////////////////////////////////

  private df_StringSet blacklist;
  private bool isPrevFlipped;

} // class df_EventHandler

class df_Unflipper : Inventory
{

// public: /////////////////////////////////////////////////////////////////////

  override
  void Tick()
  {
    if (owner == NULL) { return; }

    state raiseState = owner.ResolveState("Raise");
    bool isRevived = Actor.InStateSequence(owner.curState.NextState, raiseState);

    if (!isRevived)
    {
      if (owner.CountInv("df_MirroredFlag"))
      {
        df_EventHandler.flip(owner);
        owner.TakeInventory("df_MirroredFlag", 1);
      }

      Destroy();
    }

  }

} // class df_Unflipper

class df_StringSet
{

// public: /////////////////////////////////////////////////////////////////////

  df_StringSet init()
  {
    // must be sorted.
    values.push("ChaingunGuy"); // Doom
    values.push("Cyberdemon");  // Doom
    values.push("Draugr");      // Hell-Forged
    values.push("Hellduke");    // Hell-Forged
    values.push("Hellsmith");   // Hell-Forged

    return self;
  }

  bool contains(string s)
  {
    // binary search
    int L = 0;
    int R = values.size() - 1;

    while (L <= R)
    {
      int m = (L + R) / 2;
      string current = values[m];
      if      (current <  s) { L = m + 1; }
      else if (current >  s) { R = m - 1; }
      else if (current == s) { return true; }
    }
    return false;
  }

// private: /////////////////////////////////////////////////////////////////////

  private Array<String> values;

} // class df_StringSet

class df_MirroredFlag : Inventory {}
