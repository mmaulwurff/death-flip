version 4.2

class df_EventHandler : EventHandler
{

// public: /////////////////////////////////////////////////////////////////////

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

    bool flipped = random(0, 1);
    if (flipped)
    {
      thing.A_SetScale(-1.0, 1.0, AAPTR_DEFAULT);
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

  private df_StringSet blacklist;

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
      owner.A_SetScale(1.0, 1.0, AAPTR_DEFAULT);
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
    values.push("ChaingunGuy");
    values.push("Cyberdemon");

    return self;
  }

  bool contains(string s)
  {
    // binary search
    int size = values.size();
    int L    = 0;
    int R    = size - 1;

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

}
