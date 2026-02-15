# Home Page Components Documentation

## 📁 Component Structure

```
lib/features/home/presentation/
├── pages/
│   └── home_page.dart          # Main home page (refactored)
└── widgets/
    ├── lazada_app_bar.dart     # Orange gradient header with search
    ├── flash_sale_banner.dart  # Flash sale with live countdown
    ├── quick_access_grid.dart  # 8 quick access icons
    ├── category_section.dart   # Horizontal category list
    ├── section_header.dart     # Reusable section headers
    ├── image_carousel.dart     # Banner carousel (existing)
    └── example_products.dart   # Sample product data
```

---

## 🧩 Components Overview

### 1. **LazadaAppBar** 🔍

**File:** `lazada_app_bar.dart`

Modern gradient app bar with integrated search.

#### Features

- Orange gradient background (Lazada signature)
- Search input with camera icon
- SafeArea padding
- Responsive design

#### Usage

```dart
LazadaAppBar(
  searchController: _searchController,
  onSearchChanged: (value) {
    print("Search: $value");
  },
)
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `searchController` | `TextEditingController` | ✅ | Controls search input |
| `onSearchChanged` | `ValueChanged<String>?` | ❌ | Callback when search text changes |

---

### 2. **FlashSaleBanner** ⚡

**File:** `flash_sale_banner.dart`

Eye-catching flash sale banner with **live countdown timer**.

#### Features

- Red gradient background
- **Real-time countdown** (updates every second)
- Lightning bolt icon
- Tap gesture support
- Auto-formatted timer (HH:MM:SS)

#### Usage

```dart
FlashSaleBanner(
  onTap: () {
    // Navigate to flash sale page
  },
)
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `onTap` | `VoidCallback?` | ❌ | Callback when banner is tapped |

#### Timer Logic

- Starts at 2:45:30 by default
- Counts down every second
- Auto-stops at 00:00:00
- Uses `Timer.periodic` for updates

---

### 3. **QuickAccessGrid** 🎯

**File:** `quick_access_grid.dart`

Grid of 8 colorful quick access icons.

#### Features

- 4-column grid layout
- Customizable items
- Color-coded icons
- Tap gesture support
- Default items included

#### Default Items

1. 🏪 LazMall (Orange)
2. 🎫 Vouchers (Red)
3. 🎁 Free Shipping (Green)
4. ✨ New Arrivals (Blue)
5. 📈 Top Deals (Orange)
6. ❤️ Wishlist (Pink)
7. 💯 Clearance (Purple)
8. 🚚 Track Order (Gray)

#### Usage

```dart
// Use default items
QuickAccessGrid()

// Or customize
QuickAccessGrid(
  customItems: [
    QuickAccessItem(
      icon: Icons.store,
      label: 'Custom',
      color: Colors.blue,
      onTap: () => print('Tapped'),
    ),
  ],
)
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `customItems` | `List<QuickAccessItem>?` | ❌ | Custom quick access items |

---

### 4. **CategorySection** 📂

**File:** `category_section.dart`

Horizontal scrollable category list with colorful backgrounds.

#### Features

- Horizontal scroll
- 6 rotating colors
- Loading state support
- Category images with fallback
- Navigation to category page

#### Usage

```dart
CategorySection(
  categories: _categories,
  isLoading: _categories.isEmpty,
)
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `categories` | `List<Category>` | ✅ | List of categories to display |
| `isLoading` | `bool` | ❌ | Show loading indicator |

#### Color Rotation

```dart
[
  Color(0xFFFF6600), // Orange
  Color(0xFF2196F3), // Blue
  Color(0xFF4CAF50), // Green
  Color(0xFFE91E63), // Pink
  Color(0xFF9C27B0), // Purple
  Color(0xFFFF9800), // Amber
]
```

---

### 5. **SectionHeader** 📌

**File:** `section_header.dart`

Reusable section header with optional action button.

#### Features

- Orange accent bar (optional)
- Action button with chevron
- Consistent styling
- Dark mode support

#### Usage

```dart
// With action button
SectionHeader(
  title: "Just For You",
  actionText: "See All",
  onActionTap: () => print('See All'),
)

// Without action button
SectionHeader(
  title: "Categories",
  showAccentBar: false,
)
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `title` | `String` | ✅ | Section title text |
| `actionText` | `String?` | ❌ | Action button text |
| `onActionTap` | `VoidCallback?` | ❌ | Action button callback |
| `showAccentBar` | `bool` | ❌ | Show orange accent bar (default: true) |

---

### 6. **ExampleProducts** 🛍️

**File:** `example_products.dart`

Sample product data for testing and fallback.

#### Features

- 8 sample products with real images
- Diverse product categories
- Realistic pricing
- Fallback when API fails

#### Usage

```dart
final products = ExampleProducts.getSampleProducts();
```

#### Sample Products

1. Wireless Bluetooth Headphones - $79.99
2. Smart Watch Series 7 - $299.99
3. Portable Power Bank 20000mAh - $34.99
4. 4K Ultra HD Action Camera - $149.99
5. Gaming Mechanical Keyboard RGB - $89.99
6. Wireless Gaming Mouse - $59.99
7. USB-C Hub 7-in-1 - $45.99
8. Smartphone Stand Adjustable - $19.99

---

## 🎨 Design System

### Colors

```dart
static const Color lazadaOrange = Color(0xFFFF6600);
static const Color lazadaRed = Color(0xFFD0011B);
static const Color lazadaYellow = Color(0xFFFFC300);
```

### Spacing

- Small: `6-8px`
- Medium: `12-16px`
- Large: `20-24px`

### Border Radius

- Small: `4px`
- Medium: `8px`
- Large: `12px`

---

## 🔄 Refactored Home Page

### Before

- 400+ lines in single file
- Inline widget building
- Hard to maintain
- No reusability

### After

- ~250 lines in home_page.dart
- 6 modular components
- Easy to maintain
- Highly reusable
- Example products fallback

### Benefits

✅ **Modularity** - Each component is self-contained  
✅ **Reusability** - Use components anywhere  
✅ **Maintainability** - Easy to update individual parts  
✅ **Testability** - Test components independently  
✅ **Scalability** - Add new features easily  

---

## 📱 Usage Example

```dart
import 'package:flutter/material.dart';
import '../widgets/lazada_app_bar.dart';
import '../widgets/flash_sale_banner.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/category_section.dart';
import '../widgets/section_header.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: LazadaAppBar(
              searchController: TextEditingController(),
            ),
          ),
          
          // Flash Sale
          SliverToBoxAdapter(
            child: FlashSaleBanner(),
          ),
          
          // Quick Access
          SliverToBoxAdapter(
            child: QuickAccessGrid(),
          ),
          
          // Categories
          SliverToBoxAdapter(
            child: CategorySection(
              categories: myCategories,
            ),
          ),
          
          // Section Header
          SliverToBoxAdapter(
            child: SectionHeader(
              title: "Just For You",
              actionText: "See All",
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🚀 Next Steps

### Recommended Enhancements

1. **Add animations** to components
2. **Implement search** functionality
3. **Connect to real API** for products
4. **Add shimmer loading** states
5. **Implement pull-to-refresh**
6. **Add favorites** functionality
7. **Create flash sale page**
8. **Add product filtering**

---

**Created with ❤️ for modern, maintainable Flutter apps**
