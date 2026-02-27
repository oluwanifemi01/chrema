<div align="center">
  <img src="https://i.postimg.cc/XY8WMFy5/ideogram-v3-0-App-icon-design-for-finance-app-called-Chrema-Greek-letter-Chi-CH-in-white-purpl-0-2.png" alt="Chrema Logo" width="120" height="120"> 
  
  # Chrema
  ### Wealth Made Simple
  
  [![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios/)
  [![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)](https://swift.org/)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  
  AI-powered budget tracking app that helps you build real wealth with personalized recommendations, smart tracking, and actionable insights.
  
  [Features](#features) • [Screenshots](#screenshots) • [Tech Stack](#tech-stack) • [Installation](#installation)
</div>

---

## ✨ Features

### 🤖 AI-Powered Budgeting
- Personalized budget recommendations based on your income, location, and lifestyle
- Location-aware suggestions considering local cost of living
- Smart budget regeneration anytime

### 📊 Real-Time Tracking
- Track expenses with beautiful, intuitive interface
- Smart progress bars with color-coded warnings
- Instant alerts when approaching budget limits

### 🎯 Custom Categories
- Create unlimited custom budget categories
- Choose from 80+ icons and 12 colors
- Track pets, kids, hobbies, and more

### 🔄 Recurring Expenses
- Auto-track monthly bills (rent, subscriptions, etc.)
- Weekly, bi-weekly, or monthly frequencies
- Never forget regular payments

### 📈 Analytics & Insights
- Beautiful pie charts and visualizations
- Monthly summary reports with achievements
- AI-generated spending insights

### 🌙 Beautiful Design
- Full dark mode support
- Smooth animations and transitions
- Premium polish and attention to detail

### 🔒 Privacy First
- Secure Google authentication
- Bank-level encryption
- Your data stays yours

---

## 📱 Screenshots

<div align="center">
  <img src="https://i.postimg.cc/yYLjw88N/IMG_0574.png" alt="Home" width="200">
  <img src="https://i.postimg.cc/VLKg3kks/IMG_0575.png" alt="Tracker" width="200">
  <img src="https://i.postimg.cc/hP2sHttD/IMG_0577.png" alt="Analytics" width="200">
  <img src="https://i.postimg.cc/Kv0fd88X/IMG_0578.png" alt="Summary" width="200">
</div>

---

## 🛠 Tech Stack

- **Language**: Swift 5.9
- **Framework**: SwiftUI
- **Backend**: Firebase
  - Authentication (Google Sign-In)
  - Firestore Database
- **AI**: Anthropic Claude API
- **Architecture**: MVVM
- **Minimum iOS**: 17.0

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- Firebase account
- Anthropic API key

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/oluwanifemi01/chrema.git
   cd chrema
```

2. **Open in Xcode**
```bash
   open "Budgetly App.xcodeproj"
```

3. **Set up Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Add it to the project (not tracked in git)

4. **Add API Keys**
   - Create a `Config.swift` file (not tracked in git)
   - Add your Anthropic API key:
```swift
     struct Config {
         static let anthropicAPIKey = "your-api-key-here"
     }
```

5. **Build and Run**
   - Select a simulator or device
   - Press `Cmd + R`

---

## 📂 Project Structure
```
Chrema/
├── Models/
│   ├── Expense.swift
│   ├── BudgetItem.swift
│   ├── CustomBudgetCategory.swift
│   └── MonthlySummary.swift
├── Views/
│   ├── DashboardView.swift
│   ├── TrackerView.swift
│   ├── AnalyticsView.swift
│   ├── AddExpenseView.swift
│   ├── BudgetPreferencesView.swift
│   └── MonthlySummaryView.swift
├── Managers/
│   ├── AuthenticationManager.swift
│   ├── ExpenseManager.swift
│   ├── BudgetCategoryManager.swift
│   └── MonthlySummaryManager.swift
├── Services/
│   └── BudgetService.swift
├── Helpers/
│   ├── AnimationHelpers.swift
│   └── Colors.swift
└── Assets/
    └── Assets.xcassets
```

---

## 🎯 Roadmap

- [x] AI-powered budget generation
- [x] Expense tracking
- [x] Custom categories
- [x] Recurring expenses
- [x] Monthly summaries
- [x] Dark mode
- [ ] Push notifications for bill reminders
- [ ] Home screen widget
- [ ] Receipt scanner (OCR)
- [ ] Shared budgets for couples
- [ ] Debt tracker
- [ ] Multi-currency support

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@oluwanifemi01](https://github.com/oluwanifemi01)
- Email: o_oloyede@outlook.com

---

## 🙏 Acknowledgments

- Anthropic Claude for AI budget recommendations
- Firebase for backend infrastructure
- SwiftUI community for inspiration

---

## 📧 Contact

Have questions? Reach out at **support@chremaapp.com**/**o_oloyede@outlook.com**

---

<div align="center">
  Made with ❤️ for better financial wellness
  
  ⭐ Star this repo if you find it helpful!
</div>
```

---

## LICENSE 
```
MIT License

Copyright (c) 2026 [Oluwanifemi Oloyede]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
