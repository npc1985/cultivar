#!/usr/bin/env python3
"""
Generate app icon for Cultivar - A gardening/farming app
Creates a seedling/sprout design with earthy green tones
"""

from PIL import Image, ImageDraw
import os
import math

def create_icon(size):
    """Create an app icon with a seedling design"""
    # Create image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Colors - earthy green palette
    bg_color = (76, 139, 66)      # Meadow green
    bg_darker = (56, 102, 48)     # Darker green for depth
    stem_color = (139, 115, 85)   # Brown for stem
    leaf_light = (144, 198, 82)   # Light green for leaves
    leaf_dark = (106, 168, 56)    # Darker green for leaves

    # Draw circular background with gradient effect
    center = size // 2
    radius = size // 2

    # Create gradient background circles
    for i in range(radius, 0, -1):
        # Gradient from darker at edge to lighter in center
        ratio = i / radius
        r = int(bg_darker[0] + (bg_color[0] - bg_darker[0]) * (1 - ratio))
        g = int(bg_darker[1] + (bg_color[1] - bg_darker[1]) * (1 - ratio))
        b = int(bg_darker[2] + (bg_color[2] - bg_darker[2]) * (1 - ratio))
        color = (r, g, b)
        draw.ellipse([center - i, center - i, center + i, center + i], fill=color)

    # Draw seedling
    # Proportions relative to icon size
    stem_width = max(2, size // 40)
    stem_height = int(size * 0.45)
    stem_start_y = center + int(size * 0.15)
    stem_end_y = stem_start_y - stem_height

    # Draw stem
    stem_x = center
    draw.rounded_rectangle(
        [stem_x - stem_width, stem_end_y, stem_x + stem_width, stem_start_y],
        radius=stem_width,
        fill=stem_color
    )

    # Draw leaves
    leaf_size = int(size * 0.25)

    # Left leaf (pointing up-left)
    left_leaf_points = [
        (stem_x, stem_end_y + int(leaf_size * 0.3)),  # Base at stem
        (stem_x - int(leaf_size * 0.7), stem_end_y - int(leaf_size * 0.4)),  # Left tip
        (stem_x - int(leaf_size * 0.2), stem_end_y)  # Top curve
    ]
    draw.polygon(left_leaf_points, fill=leaf_dark)

    # Add lighter highlight to left leaf
    left_highlight = [
        (stem_x - int(leaf_size * 0.1), stem_end_y + int(leaf_size * 0.2)),
        (stem_x - int(leaf_size * 0.5), stem_end_y - int(leaf_size * 0.2)),
        (stem_x - int(leaf_size * 0.2), stem_end_y + int(leaf_size * 0.05))
    ]
    draw.polygon(left_highlight, fill=leaf_light)

    # Right leaf (pointing up-right)
    right_leaf_points = [
        (stem_x, stem_end_y + int(leaf_size * 0.3)),  # Base at stem
        (stem_x + int(leaf_size * 0.7), stem_end_y - int(leaf_size * 0.4)),  # Right tip
        (stem_x + int(leaf_size * 0.2), stem_end_y)  # Top curve
    ]
    draw.polygon(right_leaf_points, fill=leaf_dark)

    # Add lighter highlight to right leaf
    right_highlight = [
        (stem_x + int(leaf_size * 0.1), stem_end_y + int(leaf_size * 0.2)),
        (stem_x + int(leaf_size * 0.5), stem_end_y - int(leaf_size * 0.2)),
        (stem_x + int(leaf_size * 0.2), stem_end_y + int(leaf_size * 0.05))
    ]
    draw.polygon(right_highlight, fill=leaf_light)

    # Draw small soil mound at bottom
    soil_color = (101, 67, 33)  # Dark brown
    soil_y = center + int(size * 0.15)
    soil_height = int(size * 0.12)

    # Ellipse for soil mound
    draw.ellipse(
        [center - int(size * 0.15), soil_y,
         center + int(size * 0.15), soil_y + soil_height],
        fill=soil_color
    )

    return img

def generate_all_icons():
    """Generate all required icon sizes for iOS and macOS"""

    # iOS icon sizes
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024,
    }

    # macOS icon sizes
    macos_sizes = {
        'app_icon_16.png': 16,
        'app_icon_32.png': 32,
        'app_icon_64.png': 64,
        'app_icon_128.png': 128,
        'app_icon_256.png': 256,
        'app_icon_512.png': 512,
        'app_icon_1024.png': 1024,
    }

    # Generate iOS icons
    ios_path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    print(f"Generating iOS icons in {ios_path}...")
    for filename, size in ios_sizes.items():
        icon = create_icon(size)
        output_path = os.path.join(ios_path, filename)
        icon.save(output_path, 'PNG')
        print(f"  ✓ Created {filename} ({size}x{size})")

    # Generate macOS icons
    macos_path = 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    print(f"\nGenerating macOS icons in {macos_path}...")
    for filename, size in macos_sizes.items():
        icon = create_icon(size)
        output_path = os.path.join(macos_path, filename)
        icon.save(output_path, 'PNG')
        print(f"  ✓ Created {filename} ({size}x{size})")

    # Also create Android icons
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    print(f"\nGenerating Android icons...")
    for folder, size in android_sizes.items():
        folder_path = f'android/app/src/main/res/{folder}'
        os.makedirs(folder_path, exist_ok=True)
        icon = create_icon(size)
        output_path = os.path.join(folder_path, 'ic_launcher.png')
        icon.save(output_path, 'PNG')
        print(f"  ✓ Created {folder}/ic_launcher.png ({size}x{size})")

    # Create web icon
    print(f"\nGenerating web icon...")
    web_icon = create_icon(192)
    web_icon.save('web/icons/Icon-192.png', 'PNG')
    print(f"  ✓ Created web/icons/Icon-192.png (192x192)")

    web_icon_512 = create_icon(512)
    web_icon_512.save('web/icons/Icon-512.png', 'PNG')
    print(f"  ✓ Created web/icons/Icon-512.png (512x512)")

    print("\n✅ All icons generated successfully!")
    print("\n🌱 Icon Design:")
    print("   - Seedling sprouting from soil")
    print("   - Earthy green color palette")
    print("   - Circular background")
    print("   - Represents growth, cultivation, and nature")

if __name__ == '__main__':
    # Check if PIL is available
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("Error: Pillow (PIL) is not installed.")
        print("Install it with: pip3 install Pillow")
        exit(1)

    generate_all_icons()
