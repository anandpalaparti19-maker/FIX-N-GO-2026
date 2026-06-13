"""Generate correctly sized app icons without cropping brand artwork."""

from pathlib import Path

from PIL import Image, ImageOps

BASE = Path(__file__).resolve().parents[1]

TECH_APP = BASE / "apps" / "technician_app"
CUST_APP = BASE / "apps" / "customer_app"

TECH_SRC = TECH_APP / "assets" / "images" / "logo.png"
CUST_SRC = CUST_APP / "assets" / "images" / "logo.png"

IOS_CONTENTS = """{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
"""

IOS_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def open_source(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def contain_on_square(image: Image.Image, size: int, inset_ratio: float) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    inner_size = max(1, int(size * inset_ratio))
    contained = ImageOps.contain(image, (inner_size, inner_size), Image.Resampling.LANCZOS)
    x = (size - contained.width) // 2
    y = (size - contained.height) // 2
    canvas.alpha_composite(contained, (x, y))
    return canvas


def save_png(image: Image.Image, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination, "PNG")
    print(f"  saved {destination.relative_to(BASE)}")


def generate_icon(image: Image.Image, destination: Path, size: int, inset_ratio: float) -> None:
    save_png(contain_on_square(image, size, inset_ratio), destination)


def apply_icons(src: Path, app_dir: Path, label: str) -> None:
    print(f"\nProcessing {label}...")
    image = open_source(src)

    generate_icon(image, app_dir / "web" / "favicon.png", 32, 0.92)
    generate_icon(image, app_dir / "web" / "icons" / "Icon-192.png", 192, 0.9)
    generate_icon(image, app_dir / "web" / "icons" / "Icon-512.png", 512, 0.9)
    generate_icon(image, app_dir / "web" / "icons" / "Icon-maskable-192.png", 192, 0.76)
    generate_icon(image, app_dir / "web" / "icons" / "Icon-maskable-512.png", 512, 0.76)

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in android_sizes.items():
        generate_icon(
            image,
            app_dir / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher.png",
            size,
            0.88,
        )
        generate_icon(
            image,
            app_dir / "android" / "app" / "src" / "main" / "res" / folder / "ic_launcher_round.png",
            size,
            0.76,
        )

    ios_dir = app_dir / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    (ios_dir / "Contents.json").write_text(IOS_CONTENTS, encoding="utf-8")
    for filename, size in IOS_SIZES.items():
        generate_icon(image, ios_dir / filename, size, 0.82 if size < 1024 else 0.86)

    print(f"Completed {label}.")


if __name__ == "__main__":
    apply_icons(CUST_SRC, CUST_APP, "Customer App icons")
    apply_icons(TECH_SRC, TECH_APP, "Technician App icons")
