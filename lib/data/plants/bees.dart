/// Beekeeping management tasks for the Cultivation tab
/// Unlike plants, these are seasonal management tasks rather than growing schedules
library;

import '../../models/plant.dart';

/// Bee management "plants" - seasonal tasks displayed as plant-like entries
/// These use the Plant model but represent beekeeping activities
const List<Plant> bees = [
  // ===== SPRING TASKS =====
  Plant(
    id: 'bee_spring_inspection',
    commonName: 'Spring Hive Inspection',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit, // Using fruit for "production" activities
    emoji: '🐝',
    // Spring timing
    transplantWeeksBeforeFrost: 2, // Start 2 weeks before last frost
    daysToMaturity: 1,
    harvestWindowDays: 30,
    minTempTolerance: 50, // Need 50°F+ to open hive
    spacing: 'N/A',
    sunRequirement: 'Hive in morning sun',
    wateringNotes: 'Ensure water source nearby for bees',
    feedingNotes: 'Feed 1:1 sugar syrup if stores low',
    pestNotes: ['Check for varroa mites', 'Look for signs of nosema'],
    companionPlants: ['Early spring flowers', 'Crocus', 'Willow', 'Maple'],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waxingFirstQuarter,
    careNotes: '''First inspection when temps consistently above 50°F.

CHECK:
• Queen present and laying (eggs, larvae)
• Population building
• Food stores (feed if less than 2 frames of honey)
• Signs of disease (chalkbrood, foulbrood)
• Dead bees at entrance (normal after winter)
• Clean bottom board of winter debris

TASKS:
• Remove entrance reducer if population strong
• Add pollen patty if no natural pollen
• Reverse brood boxes if needed
• Replace old comb (1-2 frames per year)''',
    varieties: [],
    medicinalUses: [
      'Spring honey for seasonal allergies (local pollen)',
      'Propolis harvest for immune support',
    ],
    edibleParts: ['Honey', 'Pollen', 'Propolis'],
  ),
  Plant(
    id: 'bee_swarm_prevention',
    commonName: 'Swarm Prevention',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    // Late spring
    transplantWeeksAfterFrost: 2,
    daysToMaturity: 1,
    harvestWindowDays: 60,
    minTempTolerance: 60,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'Stop feeding when nectar flow starts',
    pestNotes: [],
    companionPlants: ['Fruit trees in bloom', 'Dandelions', 'Clover'],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waningThirdQuarter,
    careNotes: '''Peak swarm season is 4-8 weeks after first pollen.

WEEKLY INSPECTIONS - Look for:
• Queen cells (especially on frame bottoms)
• Congested brood nest
• Bearding at entrance
• Reduced laying space

PREVENTION:
• Add supers BEFORE they need them
• Checkerboard frames in spring
• Make splits from strong hives
• Ensure good ventilation
• Consider Demaree or other swarm control methods

If you find capped queen cells, the hive may have already swarmed.''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),
  Plant(
    id: 'bee_super_add',
    commonName: 'Add Honey Supers',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🍯',
    // When nectar flow starts
    transplantWeeksAfterFrost: 4,
    daysToMaturity: 1,
    harvestWindowDays: 90,
    minTempTolerance: 60,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'STOP feeding when supers are on (sugar in honey)',
    pestNotes: [],
    companionPlants: ['Black locust', 'Tulip poplar', 'Clover', 'Basswood'],
    avoidPlanting: [],
    bestMoonSigns: ['Aries', 'Leo', 'Sagittarius'],
    bestMoonPhase: MoonPhasePreference.waxingSecondQuarter,
    careNotes: '''Add supers when:
• Bees are working 7-8 of 10 frames in top box
• Nectar flow is starting (trees blooming)
• Nighttime temps consistently above 50°F

TIPS:
• Add supers ABOVE queen excluder
• Use drawn comb if available (faster)
• Add foundation supers with some drawn frames
• Add another super when current is 70% full
• "Nadiring" (adding below) can reduce swarming

NEVER add supers while feeding - contaminates honey.''',
    varieties: [],
    medicinalUses: [],
    edibleParts: ['Honey (the goal!)'],
  ),

  // ===== SUMMER TASKS =====
  Plant(
    id: 'bee_mite_treatment_summer',
    commonName: 'Varroa Mite Treatment (Summer)',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    // After honey harvest, before fall buildup
    daysToMaturity: 1,
    harvestWindowDays: 30,
    minTempTolerance: 50,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'May need to feed after treatment',
    pestNotes: ['Varroa destructor - #1 colony killer'],
    companionPlants: [],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waningFourthQuarter,
    careNotes: '''Critical! Most colony losses are varroa-related.

MONITOR (before treatment):
• Alcohol wash or sugar shake (300 bees)
• Treat if >2-3 mites per 100 bees
• Treat ALL colonies in an apiary together

TREATMENT OPTIONS (rotate annually):
• Oxalic acid (cool weather, broodless)
• Formic acid (any brood level, temp sensitive)
• Thymol (Apiguard, ApiLife) - warm weather
• Apivar strips (45 days, not organic)

TIMING: Treat after removing honey supers, before fall bees emerge (August-September is critical).''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),
  Plant(
    id: 'bee_honey_harvest',
    commonName: 'Honey Harvest',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🍯',
    // Mid-summer to early fall
    daysToMaturity: 1,
    harvestWindowDays: 60,
    minTempTolerance: 60,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'Leave minimum 60 lbs honey for winter (cold climates)',
    pestNotes: [],
    companionPlants: [],
    avoidPlanting: [],
    bestMoonSigns: ['Aries', 'Leo', 'Sagittarius'],
    bestMoonPhase: MoonPhasePreference.waningThirdQuarter,
    careNotes: '''Harvest when frames are 80%+ capped.

METHODS TO CLEAR BEES:
• Bee escape boards (24-48 hours before)
• Fume boards (quick but bees don't like it)
• Brush bees off gently

EXTRACTION:
• Uncap with hot knife or fork
• Extract in warm room (honey flows better)
• Strain through fine mesh
• Let settle 24-48 hours before bottling

LEAVE ENOUGH: In cold climates, leave 60-90 lbs honey (full deep super) for winter.''',
    varieties: [],
    medicinalUses: [
      'Raw honey for wound healing',
      'Local honey for allergies',
      'Honey for cough suppression',
      'Manuka-type honey for antibacterial use',
    ],
    edibleParts: ['Honey', 'Comb honey', 'Cappings'],
  ),

  // ===== FALL TASKS =====
  Plant(
    id: 'bee_fall_feeding',
    commonName: 'Fall Feeding',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    // 6-8 weeks before first frost
    daysToMaturity: 1,
    harvestWindowDays: 45,
    minTempTolerance: 50,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: '2:1 sugar syrup (2 parts sugar to 1 part water)',
    pestNotes: ['Watch for robbing from other hives'],
    companionPlants: ['Goldenrod', 'Asters', 'Late season flowers'],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waxingSecondQuarter,
    careNotes: '''Build winter stores before cold weather.

ASSESS STORES:
• Heft test (lift back of hive)
• Full deep = ~60-90 lbs honey
• Goal: equivalent of 60+ lbs for northern climates

2:1 SYRUP (for winter stores):
• 2 parts white sugar : 1 part water by weight
• Feed rapidly using top feeder
• Continue until bees stop taking it
• Must complete before temps drop below 50°F

Reduce entrances to prevent robbing!''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),
  Plant(
    id: 'bee_winter_prep',
    commonName: 'Winter Preparation',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    // 2-4 weeks before hard frost
    daysToMaturity: 1,
    harvestWindowDays: 30,
    minTempTolerance: 40,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'Last chance to feed if stores low',
    pestNotes: ['Final mite treatment if needed (oxalic acid when broodless)'],
    companionPlants: [],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waningFourthQuarter,
    careNotes: '''Prepare hives for winter survival.

CHECKLIST:
• Verify adequate stores (heft test)
• Reduce entrance (mouse guard)
• Combine weak hives (better one strong than two weak)
• Remove queen excluders (cluster must move to food)
• Ensure ventilation (moisture kills more than cold)
• Add moisture board or quilt box
• Wrap hives in cold climates (optional)
• Windbreak if exposed location
• Tip hives slightly forward (water drainage)

DO NOT:
• Open hives below 50°F
• Disturb cluster once formed
• Block all ventilation''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),

  // ===== WINTER TASKS =====
  Plant(
    id: 'bee_winter_check',
    commonName: 'Winter Monitoring',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    daysToMaturity: 1,
    harvestWindowDays: 90,
    minTempTolerance: 0, // Monitor even in cold
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'Emergency feed with fondant or sugar bricks if needed',
    pestNotes: ['Oxalic acid treatment when broodless (December-January)'],
    companionPlants: [],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.any,
    careNotes: '''Minimal intervention - mostly observation.

MONTHLY CHECKS (from outside):
• Clear dead bees from entrance
• Listen for cluster buzz (knock on hive)
• Check for moisture issues
• Ensure entrance not blocked by snow/ice

EMERGENCY FEEDING (if hive feels light):
• Sugar bricks on top bars
• Fondant patties
• Mountain camp method (dry sugar on newspaper)
• Only in warm spell (40°F+) if desperate

DO NOT open hive unless emergency - breaks cluster seal.''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),

  // ===== QUEEN MANAGEMENT =====
  Plant(
    id: 'bee_queen_check',
    commonName: 'Queen Status Check',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '👑',
    daysToMaturity: 1,
    harvestWindowDays: 180, // Season-long
    minTempTolerance: 60,
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'N/A',
    pestNotes: [],
    companionPlants: [],
    avoidPlanting: [],
    bestMoonSigns: ['Cancer', 'Scorpio', 'Pisces'],
    bestMoonPhase: MoonPhasePreference.waxingFirstQuarter,
    careNotes: '''Verify queenright status during inspections.

SIGNS OF QUEENRIGHT HIVE:
• Eggs (tiny grains of rice in cells)
• Young larvae (C-shaped, white)
• Consistent brood pattern
• Calm bee behavior

SIGNS OF QUEENLESS:
• No eggs or young larvae
• Laying workers (multiple eggs per cell)
• Roaring/agitated bees
• Queen cells being built

REQUEENING:
• Best in spring or late summer
• Allow 2-3 days after removing old queen
• Introduce in cage with candy plug
• Check for acceptance after 3-5 days''',
    varieties: [],
    medicinalUses: [],
    edibleParts: [],
  ),
  Plant(
    id: 'bee_propolis',
    commonName: 'Propolis Harvest',
    category: PlantCategory.bees,
    plantPart: PlantPart.fruit,
    emoji: '🐝',
    daysToMaturity: 1,
    harvestWindowDays: 60,
    minTempTolerance: 40, // Harvest when cold (brittle)
    spacing: 'N/A',
    sunRequirement: 'N/A',
    wateringNotes: 'N/A',
    feedingNotes: 'N/A',
    pestNotes: [],
    companionPlants: ['Poplar', 'Birch', 'Conifers (resin sources)'],
    avoidPlanting: [],
    bestMoonSigns: ['Taurus', 'Virgo', 'Capricorn'],
    bestMoonPhase: MoonPhasePreference.waningThirdQuarter,
    careNotes: '''Harvest propolis in fall when it's brittle.

METHODS:
• Propolis traps (replace inner cover)
• Scrape from frames and boxes
• Freeze to make brittle, then crumble

USES:
• Tincture (dissolve in alcohol)
• Throat spray
• Wound care
• Natural preservative

Propolis contains 300+ compounds with antimicrobial, antiviral, and anti-inflammatory properties.''',
    varieties: [],
    medicinalUses: [
      'Antimicrobial - fights bacteria and fungi',
      'Antiviral - traditional cold/flu remedy',
      'Wound healing - speeds tissue repair',
      'Oral health - fights gum disease',
      'Immune modulation',
      'Anti-inflammatory',
    ],
    edibleParts: ['Propolis tincture', 'Raw propolis'],
  ),
];
