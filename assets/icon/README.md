# Ícone e splash

Coloque aqui as imagens de identidade visual e gere os recursos nativos:

| Arquivo                | Tamanho      | Uso                                   |
|------------------------|--------------|---------------------------------------|
| `icon.png`             | 1024x1024    | Ícone do app                          |
| `icon_foreground.png`  | 1024x1024    | Camada frontal do ícone adaptativo    |
| `splash_logo.png`      | ~512x512     | Logo central da splash screen         |

Depois de adicionar os arquivos, gere os recursos:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

A configuração de ambos já está no `pubspec.yaml`.
