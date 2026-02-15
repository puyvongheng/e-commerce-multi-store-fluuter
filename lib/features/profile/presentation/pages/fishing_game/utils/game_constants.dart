class GameConstants {
  // Fish types
  static const fishTypes = [
    {'emoji': '🐟', 'hp': 1, 'coins': 5, 'speed': 2.0, 'size': 40.0},
    {'emoji': '🐠', 'hp': 2, 'coins': 10, 'speed': 1.5, 'size': 45.0},
    {'emoji': '🐡', 'hp': 3, 'coins': 15, 'speed': 1.0, 'size': 50.0},
    {'emoji': '🦈', 'hp': 5, 'coins': 30, 'speed': 1.2, 'size': 60.0},
    {'emoji': '🐙', 'hp': 8, 'coins': 50, 'speed': 0.8, 'size': 65.0},
    {'emoji': '🦑', 'hp': 10, 'coins': 75, 'speed': 0.7, 'size': 70.0},
    {'emoji': '🐳', 'hp': 15, 'coins': 100, 'speed': 0.5, 'size': 80.0},
  ];

  // Weapon progression
  static const weaponProgression = [
    {'level': 1, 'type': '🎣', 'bullet': '•', 'power': 1},
    {'level': 2, 'type': '🔱', 'bullet': '⚡', 'power': 3},
    {'level': 3, 'type': '💣', 'bullet': '💥', 'power': 6},
    {'level': 4, 'type': '🚀', 'bullet': '🔥', 'power': 10},
    {'level': 5, 'type': '⚛️', 'bullet': '✨', 'power': 15},
  ];

  // Combo multipliers
  static const comboMultipliers = {
    2: 1.5,
    3: 2.0,
    5: 3.0,
    10: 5.0,
    20: 10.0,
  };

  // Achievement definitions
  static const achievements = [
    {
      'id': 'first_kill',
      'name': 'ត្រីដំបូង',
      'desc': 'Kill your first fish',
      'reward': 50
    },
    {
      'id': 'combo_5',
      'name': 'Combo Master',
      'desc': 'Get 5x combo',
      'reward': 100
    },
    {
      'id': 'boss_killer',
      'name': 'Boss Slayer',
      'desc': 'Kill a boss fish',
      'reward': 200
    },
    {
      'id': 'rich',
      'name': 'អ្នកមាន',
      'desc': 'Earn 10,000 coins',
      'reward': 500
    },
    {
      'id': 'level_10',
      'name': 'ជំនាញខ្ពស់',
      'desc': 'Reach level 10',
      'reward': 300
    },
    {
      'id': 'prestige',
      'name': 'Prestige',
      'desc': 'Prestige once',
      'reward': 1000
    },
  ];

  // Spawn rates
  static const double powerUpSpawnChance = 0.3;
  static const double chestSpawnChance = 0.1;
  static const double bossSpawnInterval = 30.0; // seconds

  // Game balance
  static const int maxParticles = 200;
  static const int comboTimeWindow = 3; // seconds
  static const double criticalHitMultiplier = 2.0;
  static const int nuclearExplosionCost = 1000;

  // Weather types
  static const weatherTypes = ['clear', 'rain', 'storm', 'wind'];
  static const double weatherChangeDuration = 20.0; // seconds
}
