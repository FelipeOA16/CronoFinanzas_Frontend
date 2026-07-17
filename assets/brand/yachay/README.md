Agregar en esta carpeta:

- `yachay_default.png`
- `yachay_happy.png`
- `yachay_thinking.png`
- `yachay_warning.png`
- `yachay_success.png`
- `yachay_empty.png`

Uso esperado:

```dart
CFYachayCard(
  imageAsset: BrandAssets.yachayDefault,
  showMascot: true,
  // ...
)
```

Mientras la imagen no exista, `CFYachayCard` mantiene su placeholder actual.
