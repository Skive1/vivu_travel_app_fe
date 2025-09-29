# Schedule Screen UI

This document describes the Schedule screen implementation for the ViVu Travel app, designed based on the provided Android XML layout.

## Overview

The Schedule screen provides a comprehensive calendar view and schedule management interface for travel planning. It reuses existing home widgets while adding schedule-specific functionality.

## Architecture

### Screen Structure
```
ScheduleScreen
├── ScheduleContainer (rounded container with shadow)
└── ScheduleContent
    ├── HomeHeader (reused from home feature)
    ├── ScheduleCalendar (monthly calendar view)
    ├── ScheduleList (list of schedule items)
    ├── HomeBottomNav (reused from home feature)
    └── ScheduleFab (floating action button)
```

### Widgets Created

#### 1. ScheduleScreen
- Main screen widget with fade animation
- Handles system UI overlay styling
- Uses ScheduleContainer for the rounded layout

#### 2. ScheduleContainer
- Provides the rounded container with shadow effect
- Matches the Android XML design with 30px border radius
- Contains ScheduleContent

#### 3. ScheduleContent
- Main content coordinator
- Integrates home widgets (header, bottom nav)
- Manages navigation between tabs
- Contains calendar and schedule list sections

#### 4. ScheduleCalendar
- Interactive weekly calendar (7 days view)
- Week navigation with chevron buttons
- Date selection with visual feedback
- Vietnamese day labels (T2, T3, T4, T5, T6, T7, CN)
- Dynamic week range display

#### 5. ScheduleList
- Displays schedule items for selected date only
- Dynamic filtering based on selected date
- Empty state when no schedules for selected date
- Smart header text (hôm nay, ngày mai, hôm qua, specific date)
- Mock data included for demonstration
- Schedule item cards with type-based styling
- Modal bottom sheet for schedule details

#### 6. ScheduleItem
- Individual schedule item card
- Type-based color coding and icons
- Shows time, location, participants, price
- Status indicators (upcoming, ongoing, completed, cancelled)

#### 7. ScheduleFab
- Floating action button for adding new schedules
- Modal bottom sheet with schedule type selection
- Animated interactions (scale and rotation)

## Features

### Calendar Features
- Weekly view (7 days only)
- Week navigation (previous/next week)
- Date selection with callback
- Today highlighting
- Selected date indication
- Dynamic week range display
- Vietnamese localization

### Schedule Management
- Date-based filtering (only shows schedules for selected date)
- Multiple schedule types (tour, dining, accommodation, shopping, transport)
- Visual type indicators with colors and icons
- Price display with formatting
- Participant count
- Status tracking
- Empty state handling
- Smart header text based on selected date

### Navigation
- Integrated bottom navigation
- Tab switching between home, explore, schedule, chat, profile
- Route management through AppRoutes

### Mock Data
The implementation includes comprehensive mock data for demonstration:
- 5 sample schedule items
- Different schedule types
- Various time slots and locations
- Price ranges and participant counts

## Usage

### Navigation
```dart
// Navigate to schedule screen
Navigator.pushNamed(context, '/schedule');
```

### Adding Schedule Route
The schedule route has been added to `lib/routes.dart`:
```dart
static const String schedule = '/schedule';

case schedule:
  return MaterialPageRoute(
    builder: (_) => const ScheduleScreen(),
  );
```

## Design Specifications

### Colors
- Primary: #24BAEC (blue)
- Accent: #F6AE2D (yellow)
- Secondary: #F24236 (red)
- Success: #4CAF50 (green)
- Info: #2196F3 (blue)

### Layout
- Container border radius: 30px
- Card border radius: 16px
- Shadow: 0px 10px 20px rgba(0,0,0,0.1)
- Padding: 16px margins, 20px internal padding

### Typography
- Headers: 18px, FontWeight.w600
- Body text: 16px, FontWeight.w400
- Secondary text: 14px, FontWeight.w400
- Small text: 12px, FontWeight.w500

## Future Enhancements

1. **API Integration**: Replace mock data with real API calls
2. **Data Models**: Create proper entity classes for schedule data
3. **State Management**: Implement BLoC pattern for schedule management
4. **Persistence**: Add local storage for offline schedule access
5. **Notifications**: Schedule reminder notifications
6. **Sharing**: Export schedule to calendar apps
7. **Collaboration**: Share schedules with travel companions

## Dependencies

- flutter/material.dart
- flutter/services.dart
- flutter_bloc (for future state management)
- Existing app constants and colors
- Reused home widgets (header, bottom navigation)
