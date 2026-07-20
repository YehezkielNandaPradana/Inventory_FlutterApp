# Inventory App

A comprehensive Flutter-based inventory management application designed for efficient stock tracking and management. Built with a clean, modern interface featuring a professional blue and white color scheme, intuitive navigation, and real-time stock status indicators.

## ✨ Features

- **📊 Dashboard Overview**: Real-time statistics including total items, low stock alerts, and category breakdowns
- **📦 Item Management**: Complete CRUD operations for inventory items with detailed views
- **🏷️ Category Organization**: Organize items by customizable categories for better classification
- **📈 Stock Tracking**: Visual stock level indicators with color-coded status (Safe/Low/Out of stock)
- **🔍 Search & Filter**: Quickly find items with intelligent search and filtering capabilities
- **📱 Responsive Design**: Optimized for mobile devices with adaptive layouts
- **🔐 Secure Authentication**: User login system to protect inventory data
- **🎨 Beautiful UI**: Thoughtfully designed interface following modern design principles

## 🎨 Design System

The application implements a carefully crafted design system focused on usability and visual clarity:

### Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| `primary-blue` | `#2D7DD2` | Primary buttons, active icons, headers |
| `sky-blue` | `#5FA8E0` | Secondary accents, hover states |
| `light-blue-bg` | `#EAF4FF` | Card backgrounds, input fields |
| `pure-white` | `#FFFFFF` | Main screen backgrounds |
| `navy-text` | `#1B2B4B` | Headings, important text |
| `slate-text` | `#6B7A99` | Secondary text, descriptions |
| `success-green` | `#4CAF93` | Safe stock status |
| `warning-amber` | `#F2A93B` | Low stock status |
| `danger-red` | `#E5534B` | Out of stock status |

### Typography
- **Headings**: Poppins font (SemiBold) for modern, rounded appearance
- **Body Text**: Inter font (Regular) for optimal readability
- **Stock Numbers**: Inter font with tabular numbers for aligned numeric display

### Signature Elements
- **Circular Progress Bar**: Unique horizontal capsule progress bar showing stock levels
- **Status Indicators**: Color-coded badges and left-border accents on item cards
- **Clean Layout**: Ample white space with blue accents for visual hierarchy

## 🏗️ Architecture

The app follows a feature-based architecture for maintainability and scalability:

```
lib/
├── main.dart                 # Application entry point
├── app.dart                  # MaterialApp setup and routing
├── config/                   # Theme, colors, text styles, constants
│   ├── theme.dart
│   ├── colors.dart
│   ├── text_styles.dart
│   ├── routes.dart
│   └── constants.dart
├── models/                   # Data models (Barang, Kategori, Transaksi)
├── services/                 # Data access layer (Database operations)
├── providers/                # State management (Provider/Riverpod)
├── screens/                  # UI screens organized by feature
│   ├── dashboard/
│   ├── barang/               # Item management (list, detail, form)
│   ├── kategori/
│   └── stok/
├── widgets/                  # Reusable UI components
│   ├── common/               # Buttons, inputs, badges, progress bars
│   ├── cards/                # Item cards
│   └── navigation/           # Bottom navigation bar
└── utils/                    # Helper functions (validation, formatting)
```

## 🛠️ Technology Stack

- **Framework**: Flutter 3.11.5+
- **Language**: Dart SDK ^3.11.5
- **State Management**: Provider/Riverpod
- **Database**: SQLite (local storage)
- **UI Toolkit**: Material Design 3
- **Fonts**: Google Fonts (Poppins, Inter)
- **Icons**: Cupertino Icons
- **Linting**: Flutter Lints

## 📋 Dependencies

See `pubspec.yaml` for complete dependency list. Key dependencies include:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  # State management, database, and other packages...
```

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK 3.11.5 or higher
- Dart SDK ^3.11.5
- Android Studio / VS Code with Flutter plugins
- Android Emulator / iOS Simulator / Physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inventory_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform Support
- Android (min SDK 21)
- iOS (min version 12.0)
- Web (Chrome, Firefox, Safari, Edge)
- Windows, macOS, Linux (desktop)

## 📁 Project Structure

```
inventory_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── utils/
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── desain.md           # Design system documentation
└── struktur-folder.md  # Architecture documentation
```

## 🧪 Testing

Run tests to ensure application stability:

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# All tests
flutter test
```

## 📱 Screenshots

*(Add screenshots here showing:*
- *Login screen*
- *Dashboard overview*
- *Item list view*
- *Item detail screen*
- *Add/edit item form*
- *Category management*
- *Stock status indicators*)*

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows:
- Existing code style and conventions
- Proper documentation with comments
- Meaningful commit messages
- Testing for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, questions, or feedback:
- Open an issue in the repository
- Contact the development team
- Refer to the documentation in `desain.md` and `struktur-folder.md`

---

*Built with Flutter ❤️*
*Design System: Blue & White · Clean · Modern*
*Last updated: July 19, 2026*