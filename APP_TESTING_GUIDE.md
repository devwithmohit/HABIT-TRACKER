# Habit Tracker - Complete App Testing Guide

## 📱 App Overview

A clean, minimalist habit tracker with premium features for power users.

---

## 🧭 Complete App Flow

### 1️⃣ **Home Dashboard** (Main Screen)

**What you see:**

- ✅ List of all your habits
- 📊 Today's progress card showing completion stats
- ➕ Floating Action Button (FAB) to add new habits
- ⚙️ Settings gear icon in app bar

**Actions you can perform:**

- **Tap habit checkbox** → Mark habit as complete/incomplete for today
- **Tap habit tile** → View habit details (future feature)
- **Tap + button** → Navigate to Add Habit screen
- **Tap settings icon** → Navigate to Settings screen
- **Pull down** → Refresh habits list (future feature)

**Empty state:**

- Shows "No habits yet" message
- Prompts to tap + button

---

### 2️⃣ **Add Habit Screen**

**Purpose:** Create new habits with customization

**Flow:**

1. **Enter habit name** (Required)

   - Tap text field
   - Type habit name (e.g., "Morning workout")
   - Shows error if empty on save

2. **Choose icon** 🎯

   - Tap the icon container
   - Opens icon picker dialog with 24+ emoji icons
   - Select one (🎯, 💪, 📚, 🏃, 🧘, etc.)
   - Dialog closes automatically

3. **Select active days**

   - Tap day buttons (Mon-Sun)
   - Selected days are highlighted
   - Must select at least one day
   - Default: Weekdays (Mon-Fri)

4. **Pick color** 🎨

   - Tap the color container
   - Opens color picker with 20 preset colors
   - Select your favorite color
   - Dialog closes automatically

5. **Save habit**
   - Tap "Save" button in app bar
   - Shows loading indicator
   - Success: "Habit created successfully!" message
   - Automatically returns to Home Dashboard
   - New habit appears in the list

**Validation:**

- ❌ Empty name → Shows error message
- ❌ No days selected → "Please select at least one day"
- ✅ All valid → Saves habit

---

### 3️⃣ **Settings Screen**

**Purpose:** Configure app preferences and access premium features

#### **Appearance Section**

**Theme Selector:**

- Tap "Theme" option
- Choose from:
  - 🌞 Light mode
  - 🌙 Dark mode
  - 🌑 AMOLED Dark (true black)
  - 📱 System (follows device theme)
- Changes apply immediately

#### **Notifications Section**

**Enable Notifications Toggle:**

- Switch ON/OFF to enable/disable all reminders
- Updates instantly

**Reminder Time Picker:**

- Tap "Reminder Time"
- Opens native time picker
- Select preferred reminder time
- Default: 20:00 (8:00 PM)

**Skip Weekends Toggle:**

- Enable to skip reminders on Saturday & Sunday
- Useful for work-related habits

#### **Data Section**

**Export Data** 🔒 (Premium Feature)

- **Free users:**

  - Shows lock icon 🔒
  - Shows "Premium feature" subtitle
  - Tap → "Premium Feature Required" dialog
  - Option to upgrade

- **Premium users:**
  - Shows chevron icon →
  - Tap → Export format dialog
  - Choose CSV or PDF
  - Shows "Exporting..." progress
  - Success message on completion

**Clear All Data** ⚠️

- **Purpose:** Delete ALL habits, logs, and settings
- **WARNING:** Cannot be undone!
- **Flow:**
  1. Tap "Clear All Data"
  2. Confirmation dialog appears with warnings
  3. Lists what will be deleted:
     - All habits
     - All progress logs
     - All settings (except premium status)
  4. Tap "Cancel" or "Clear Everything"
  5. Shows loading indicator
  6. Success: "All data cleared" message
  7. Returns to empty home screen

#### **Premium Section**

**For Free Users:**

- Shows attractive premium card with:
  - ⭐ "Go Premium" title
  - List of premium features:
    - 📊 Export data to CSV/PDF
    - 📈 Advanced analytics
    - ☁️ Cloud backup & sync
    - 🎨 Custom themes & icons
    - 🚫 Remove ads
  - Price: $4.99 (one-time payment)
  - "Upgrade Now" button

**Upgrade Flow:**

1. Tap "Upgrade Now"
2. Premium features dialog appears
3. Shows features + price
4. Tap "Purchase Now"
5. Shows "Processing purchase..." loading
6. (Currently simulated - activates premium for testing)
7. Success: "Welcome to Premium!" dialog
8. Premium badge appears in settings app bar

**For Premium Users:**

- Premium badge (⭐ Premium) in app bar
- No premium section shown
- All premium features unlocked

#### **About Section**

- **Version:** Shows app version (1.0.0)
- **Privacy Policy:** Opens privacy policy (future)
- **Terms of Service:** Opens terms (future)

---

## 🎯 Testing Checklist

### ✅ **Home Screen Tests**

- [ ] App opens without crashes
- [ ] Empty state shows correctly
- [ ] FAB (+) button opens Add Habit screen
- [ ] Settings icon opens Settings screen
- [ ] Habits list displays created habits
- [ ] Check/uncheck habits works
- [ ] Progress card updates correctly

### ✅ **Add Habit Tests**

- [ ] Can enter habit name
- [ ] Icon picker opens and works
- [ ] All 24+ icons selectable
- [ ] Day selector toggles work
- [ ] Must select at least one day
- [ ] Color picker opens and works
- [ ] All 20 colors selectable
- [ ] Save button creates habit
- [ ] Returns to home after save
- [ ] New habit appears in list
- [ ] Validation works (empty name)

### ✅ **Settings Tests**

**Appearance:**

- [ ] Theme picker opens
- [ ] All 4 themes work (Light/Dark/AMOLED/System)
- [ ] Theme changes apply immediately

**Notifications:**

- [ ] Enable toggle works
- [ ] Time picker opens
- [ ] Time selection saves
- [ ] Skip weekends toggle works

**Data Management:**

- [ ] Export shows lock for free users
- [ ] Export works for premium users
- [ ] Export dialog shows CSV/PDF options
- [ ] Clear data shows warning dialog
- [ ] Clear data actually deletes habits
- [ ] Clear data shows success message

**Premium:**

- [ ] Premium card shows for free users
- [ ] Feature list displays correctly
- [ ] Upgrade button works
- [ ] Premium dialog shows
- [ ] Purchase flow works
- [ ] Premium activates successfully
- [ ] Premium badge appears
- [ ] Premium features unlock
- [ ] Export data now accessible

### ✅ **Premium Feature Gating**

- [ ] Free users see lock icons
- [ ] Tapping locked features shows upgrade prompt
- [ ] Premium users don't see locks
- [ ] Premium users can access all features

---

## 🐛 Known Issues / Future Features

**Current Limitations:**

- ❌ Edit habit not implemented yet
- ❌ Delete individual habit not implemented
- ❌ Habit detail view not implemented
- ❌ Calendar view not implemented
- ❌ Analytics/streaks calculation partial
- ❌ Actual IAP integration (currently simulated)
- ❌ Export functionality is placeholder
- ❌ Cloud backup not implemented
- ❌ No onboarding flow

**Planned Features:**

- 🔄 Pull to refresh
- 📊 Advanced analytics dashboard
- 📅 Calendar view with heatmap
- ✏️ Edit existing habits
- 🗑️ Delete individual habits
- 📱 Notifications system integration
- ☁️ Cloud sync (Firebase)
- 📤 Actual CSV/PDF export
- 🎨 More themes and icons
- 🌍 Multi-language support

---

## 🚀 Quick Start for Testers

1. **First Launch:**

   - App opens to empty home screen
   - Tap + button to create first habit

2. **Create a habit:**

   - Name: "Morning Exercise"
   - Icon: 🏃
   - Days: Mon-Fri
   - Color: Blue
   - Save

3. **Test marking complete:**

   - Tap checkbox next to habit
   - Should show as completed

4. **Try premium features:**

   - Go to Settings
   - Tap "Export Data" → See lock
   - Tap "Upgrade Now"
   - Complete purchase (simulated)
   - Try export again → Should work

5. **Test clear data:**
   - Go to Settings → Data
   - Tap "Clear All Data"
   - Confirm deletion
   - Return to empty home

---

## 💡 Tips for Testing

1. **Test theme changes** in different times of day
2. **Create multiple habits** to see list behavior
3. **Test with 1 day vs all 7 days** selected
4. **Try clearing data** to reset app state
5. **Test premium upgrade** to see locked features
6. **Check notifications** settings persistence

---

## 📞 Reporting Issues

When reporting bugs, include:

- Device model and Android/iOS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if possible
- Error messages

---

**Version:** 1.0.0
**Last Updated:** January 31, 2026
**Status:** Alpha Testing
