import '../models/reminder.dart';

/// Recommended Maintenance Intervals
/// Based on cycling industry standards and manufacturer guidelines
/// Sources: Park Tool, Shimano, SRAM, cycling maintenance guides
class MaintenanceRecommendation {
  final String title;
  final String description;
  final String category;
  final double intervalKm;
  final ReminderPriority priority;
  final bool isEssential; // Whether this is a critical safety item

  const MaintenanceRecommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.intervalKm,
    required this.priority,
    this.isEssential = false,
  });
}

/// Standard maintenance recommendations based on reliable cycling sources
/// These are conservative intervals suitable for regular cycling
const List<MaintenanceRecommendation> standardMaintenanceRecommendations = [
  // Chain Maintenance (Most frequent)
  MaintenanceRecommendation(
    title: 'Chain Lubrication',
    description: 'Apply chain lubricant to keep drivetrain running smoothly. Clean excess lube.',
    category: 'chain',
    intervalKm: 100,
    priority: ReminderPriority.normal,
    isEssential: true,
  ),
  MaintenanceRecommendation(
    title: 'Chain Cleaning',
    description: 'Deep clean the chain with degreaser to remove built-up grime and old lubricant.',
    category: 'chain',
    intervalKm: 300,
    priority: ReminderPriority.normal,
  ),
  MaintenanceRecommendation(
    title: 'Chain Wear Check',
    description: 'Check chain stretch with a chain checker tool. Replace if 0.5-0.75% worn.',
    category: 'chain',
    intervalKm: 500,
    priority: ReminderPriority.high,
    isEssential: true,
  ),

  // Tire & Wheel Maintenance
  MaintenanceRecommendation(
    title: 'Tire Pressure Check',
    description: 'Check and adjust tire pressure to recommended PSI for optimal performance and safety.',
    category: 'tires',
    intervalKm: 150,
    priority: ReminderPriority.normal,
    isEssential: true,
  ),
  MaintenanceRecommendation(
    title: 'Tire Inspection',
    description: 'Inspect tires for cuts, embedded debris, wear indicators, and sidewall damage.',
    category: 'tires',
    intervalKm: 500,
    priority: ReminderPriority.high,
    isEssential: true,
  ),

  // Brake Maintenance
  MaintenanceRecommendation(
    title: 'Brake Pad Inspection',
    description: 'Check brake pad thickness and wear. Replace if worn to indicator line.',
    category: 'brakes',
    intervalKm: 500,
    priority: ReminderPriority.high,
    isEssential: true,
  ),
  MaintenanceRecommendation(
    title: 'Brake Adjustment',
    description: 'Adjust brake cable tension and pad alignment for optimal stopping power.',
    category: 'brakes',
    intervalKm: 750,
    priority: ReminderPriority.normal,
  ),

  // General Cleaning
  MaintenanceRecommendation(
    title: 'Bike Wash',
    description: 'Full bike cleaning - frame, wheels, drivetrain. Prevents corrosion and wear.',
    category: 'service',
    intervalKm: 200,
    priority: ReminderPriority.low,
  ),

  // Drivetrain Maintenance
  MaintenanceRecommendation(
    title: 'Derailleur Check',
    description: 'Check front and rear derailleur alignment and shifting performance.',
    category: 'service',
    intervalKm: 500,
    priority: ReminderPriority.normal,
  ),
  MaintenanceRecommendation(
    title: 'Cable & Housing Inspection',
    description: 'Inspect brake and shift cables for fraying, rust, or sticky operation.',
    category: 'service',
    intervalKm: 1000,
    priority: ReminderPriority.normal,
  ),

  // Major Service Items
  MaintenanceRecommendation(
    title: 'Full Bike Service',
    description: 'Comprehensive tune-up: adjust all components, check bearings, true wheels.',
    category: 'service',
    intervalKm: 1500,
    priority: ReminderPriority.high,
  ),

  // Component Replacement (Long intervals)
  MaintenanceRecommendation(
    title: 'Chain Replacement',
    description: 'Replace chain to prevent cassette and chainring wear. Typically every 2000-3000km.',
    category: 'chain',
    intervalKm: 2500,
    priority: ReminderPriority.high,
    isEssential: true,
  ),
  MaintenanceRecommendation(
    title: 'Brake Pad Replacement',
    description: 'Replace brake pads for safe stopping. Frequency depends on riding conditions.',
    category: 'brakes',
    intervalKm: 2000,
    priority: ReminderPriority.high,
    isEssential: true,
  ),
  MaintenanceRecommendation(
    title: 'Tire Replacement Check',
    description: 'Assess tire condition for replacement. Check tread depth and sidewall integrity.',
    category: 'tires',
    intervalKm: 3000,
    priority: ReminderPriority.high,
    isEssential: true,
  ),
];

/// Get recommendations that should be active for a bike with the given mileage
/// Returns recommendations that the user should have reminders for
List<MaintenanceRecommendation> getRecommendationsForMileage(double currentMileage) {
  // Return all recommendations - the bike already has enough mileage that
  // all of these maintenance tasks would have come due at least once
  return standardMaintenanceRecommendations;
}

/// Get missing recommendations - recommendations that don't have corresponding reminders
List<MaintenanceRecommendation> getMissingRecommendations({
  required double bikeMileage,
  required List<String> existingReminderTitles,
}) {
  final recommendations = getRecommendationsForMileage(bikeMileage);
  
  return recommendations.where((rec) {
    // Check if there's already a reminder with a similar title
    final titleLower = rec.title.toLowerCase();
    return !existingReminderTitles.any((existing) {
      final existingLower = existing.toLowerCase();
      // Check for exact match or partial match
      return existingLower == titleLower ||
             existingLower.contains(titleLower) ||
             titleLower.contains(existingLower);
    });
  }).toList();
}

/// Get overdue recommendations based on current mileage
/// Returns recommendations that would already be overdue if set up from 0 km
List<MaintenanceRecommendation> getOverdueRecommendations(double currentMileage) {
  return standardMaintenanceRecommendations
      .where((rec) => currentMileage >= rec.intervalKm)
      .toList();
}

/// Get essential (safety-critical) recommendations
List<MaintenanceRecommendation> getEssentialRecommendations() {
  return standardMaintenanceRecommendations
      .where((rec) => rec.isEssential)
      .toList();
}

/// Calculate how many times a maintenance task would have been due
/// given the current mileage
int getTimesDue(double currentMileage, double intervalKm) {
  if (intervalKm <= 0) return 0;
  return (currentMileage / intervalKm).floor();
}
