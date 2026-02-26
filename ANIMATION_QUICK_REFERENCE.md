# Animation System Quick Reference

## How to Use the Animation Helpers

### 1. Animated Numbers

Display numbers that smoothly count up when they appear or change:

```swift
// Currency format (shows $1,234)
AnimatedNumber(value: budget.monthlySavings, format: .currency)
    .font(.system(size: 48, weight: .bold))

// Percentage format (shows 56%)
AnimatedNumber(value: savingsPercentage, format: .percentage)
    .font(.system(size: 14, weight: .medium))

// Plain number format (shows 1234)
AnimatedNumber(value: dayCount, format: .plain)
    .font(.system(size: 20, weight: .regular))
```

### 2. Card Entrance Animations

Make cards smoothly appear with scale and fade:

```swift
VStack {
    // Your card content
}
.padding(20)
.background(Color.white)
.cornerRadius(16)
.cardAppear(delay: 0.2)  // Delay in seconds
```

**Stagger multiple cards:**
```swift
VStack(spacing: 16) {
    Card1().cardAppear(delay: 0.1)
    Card2().cardAppear(delay: 0.2)
    Card3().cardAppear(delay: 0.3)
    Card4().cardAppear(delay: 0.4)
}
```

### 3. Button Press Animations

Add tactile feedback to buttons:

```swift
Button(action: doSomething) {
    Text("Press Me")
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
}
.pressAnimation()  // Adds scale + haptic feedback
```

### 4. Animated Progress Bars

Show progress with smooth animations:

```swift
AnimatedProgressBar(
    value: spent,        // Current value
    total: budget,       // Maximum value
    color: .green        // Bar color
)
.frame(height: 10)
```

The bar automatically:
- Calculates percentage
- Animates width changes
- Handles value updates
- Caps at 100%

### 5. Shimmer Effect (Loading States)

Add a shimmer to indicate loading:

```swift
RoundedRectangle(cornerRadius: 12)
    .fill(Color.gray.opacity(0.2))
    .frame(height: 80)
    .shimmer()  // Adds animated shimmer overlay
```

### 6. Success Checkmark

Show a success animation (typically in overlays):

```swift
.overlay {
    if showSuccess {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                SuccessCheckmark()
                
                Text("Success!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}
```

## Animation Parameters Reference

### Spring Animations

Common spring configurations used in the app:

| Use Case | Response | Damping | Description |
|----------|----------|---------|-------------|
| Quick buttons | 0.3 | 0.6 | Snappy, responsive |
| Tab transitions | 0.4 | 0.7 | Bouncy, playful |
| Card entrances | 0.6 | 0.7 | Smooth, elegant |
| Progress bars | 1.0 | 0.8 | Slower, deliberate |

```swift
// Quick and snappy
.animation(.spring(response: 0.3, dampingFraction: 0.6))

// Bouncy and playful
.animation(.spring(response: 0.4, dampingFraction: 0.7))

// Smooth and elegant
.animation(.spring(response: 0.6, dampingFraction: 0.7))

// Slower and deliberate
.animation(.spring(response: 1.0, dampingFraction: 0.8))
```

### Linear Animations

For continuous effects like shimmer:

```swift
.animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
```

### EaseOut Animations

For number counting:

```swift
.animation(.easeOut(duration: 1.2))
```

## Haptic Feedback Reference

### UIImpactFeedbackGenerator

Provides tactile feedback for actions:

```swift
// Light tap (for tabs, small buttons)
let impact = UIImpactFeedbackGenerator(style: .light)
impact.impactOccurred()

// Medium tap (for main actions)
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Heavy tap (for important actions)
let impact = UIImpactFeedbackGenerator(style: .heavy)
impact.impactOccurred()
```

### UINotificationFeedbackGenerator

For success/error states:

```swift
let notification = UINotificationFeedbackGenerator()

// Success (expense added, goal reached)
notification.notificationOccurred(.success)

// Warning (budget alert)
notification.notificationOccurred(.warning)

// Error (operation failed)
notification.notificationOccurred(.error)
```

## Common Patterns

### 1. Animated Value with Haptic Feedback

```swift
Button(action: {
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
    
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
        value += 10
    }
}) {
    Text("Increment")
}
```

### 2. Success Flow with Auto-Dismiss

```swift
func saveData() {
    // Save your data
    dataManager.save()
    
    // Show success
    showSuccess = true
    
    // Haptic
    let notification = UINotificationFeedbackGenerator()
    notification.notificationOccurred(.success)
    
    // Auto-dismiss after delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        dismiss()
    }
}
```

### 3. List with Staggered Card Animations

```swift
VStack(spacing: 16) {
    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        ItemCard(item: item)
            .cardAppear(delay: Double(index) * 0.1)
    }
}
```

### 4. Value Change with Animation

```swift
@State private var amount: Double = 0

// Later in your code:
withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
    amount = newAmount
}

// In your view:
AnimatedNumber(value: amount, format: .currency)
```

## Performance Tips

1. **Limit simultaneous animations**: Don't animate hundreds of items at once
2. **Use `.animation()` sparingly**: Prefer explicit `withAnimation` blocks
3. **Avoid animating large lists**: Use pagination or virtual scrolling
4. **Test on older devices**: Animations should degrade gracefully
5. **Respect accessibility settings**: Check for Reduce Motion

## Accessibility Considerations

Always respect user preferences:

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Use simpler animations when reduce motion is enabled
.cardAppear(delay: reduceMotion ? 0 : 0.2)

// Or skip animations entirely
if !reduceMotion {
    withAnimation {
        // Animate something
    }
} else {
    // Just change the value directly
}
```

## Debugging Animations

Enable slow animations in iOS Simulator:
1. Debug menu → Slow Animations (Cmd+T)
2. Or run app with: Product → Scheme → Edit Scheme → Run → Arguments → Add `-UIViewAnimationSpeed 0.1`

Check animation performance:
```swift
// In Xcode: Debug → View Debugging → Rendering
// Enable:
// - Color Blended Layers
// - Color Hits Green and Misses Red
// - Color Immediately
```

## Common Issues & Solutions

### Issue: Animations feel too fast
**Solution**: Increase response time:
```swift
.spring(response: 0.6, dampingFraction: 0.7)  // Slower
```

### Issue: Animations feel sluggish
**Solution**: Decrease response time:
```swift
.spring(response: 0.3, dampingFraction: 0.6)  // Faster
```

### Issue: Animations are too bouncy
**Solution**: Increase damping fraction:
```swift
.spring(response: 0.4, dampingFraction: 0.9)  // Less bounce
```

### Issue: Numbers jump instead of animating
**Solution**: Make sure the parent view has a stable identity:
```swift
AnimatedNumber(value: amount, format: .currency)
    .id(amount)  // Force recreation on value change
```

### Issue: Cards don't animate on first appearance
**Solution**: Ensure the view has an `.onAppear`:
```swift
.cardAppear(delay: 0.2)
.onAppear {
    // This triggers the animation
}
```

## Examples by Screen

### Home Screen
- Main savings card: `.cardAppear(delay: 0.1)`
- Budget items: Staggered with 0.1s increments
- Numbers: `AnimatedNumber` for all values

### Tracker Screen
- Monthly summary: `.cardAppear(delay: 0.1)`
- Progress bars: `AnimatedProgressBar`
- Percentages: `AnimatedNumber`

### Add Expense Screen
- Main button: `.pressAnimation()`
- Success overlay: `SuccessCheckmark()`

### Tab Bar
- Tab transitions: `.spring(response: 0.4, dampingFraction: 0.7)`
- Haptic: `.light` style

## Need Help?

Common questions:
1. **How do I make animation slower?** → Increase `response` value
2. **How do I make it less bouncy?** → Increase `dampingFraction` (closer to 1.0)
3. **How do I disable for accessibility?** → Check `@Environment(\.accessibilityReduceMotion)`
4. **Can I chain animations?** → Yes, use sequential `.asyncAfter` blocks
5. **How do I animate on value change?** → Use `.onChange(of: value)` modifier
