class BotCharacter {
  final String name;
  final String archetype;
  final double riskFactor;    // -0.5 (cautious) to +0.5 (aggressive)
  final int skillLevel;       // 1 (basic) to 3 (expert)
  final String description;
  
  const BotCharacter({
    required this.name,
    required this.archetype,
    required this.riskFactor,
    required this.skillLevel,
    required this.description,
  });
  
  // Character definitions
  static const magnus = BotCharacter(
    name: 'Magnus',
    archetype: 'Der Profi',
    riskFactor: 0.0,
    skillLevel: 3,
    description: 'Perfect memory, optimal play',
  );
  
  static const pythia = BotCharacter(
    name: 'Pythia',
    archetype: 'Die Intuitive',
    riskFactor: 0.15,
    skillLevel: 2,
    description: 'Good memory, slightly risky',
  );
  
  static const nero = BotCharacter(
    name: 'Nero',
    archetype: 'Der Aggressor',
    riskFactor: 0.35,
    skillLevel: 2,
    description: 'Average memory, rounds up',
  );
  
  static const aura = BotCharacter(
    name: 'Aura',
    archetype: 'Die Vorsichtige',
    riskFactor: -0.3,
    skillLevel: 2,
    description: 'Average memory, plays safe',
  );
  
  static const varius = BotCharacter(
    name: 'Varius',
    archetype: 'Der Chaot',
    riskFactor: 0.0,
    skillLevel: 1,
    description: 'Poor memory, unpredictable',
  );
  
  static const sol = BotCharacter(
    name: 'Sol',
    archetype: 'Der Optimist',
    riskFactor: 0.2,
    skillLevel: 2,
    description: 'Good memory, overvalues mid cards',
  );
  
  static const allCharacters = [
    magnus,
    pythia,
    nero,
    aura,
    varius,
    sol,
  ];
}
