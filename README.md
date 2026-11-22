# BookSmart

Aplicación web de Flutter para explorar, buscar y consultar libros y recursos educativos.

## Despliegue en GitHub Pages

Este proyecto está preparado para publicarse en GitHub Pages usando GitHub Actions.
En cada publicación de la rama `main`, el flujo también construye el APK de
Android y lo incluye en `downloads/booksmart.apk`. El botón de descarga aparece
solo en la versión web, en la parte inferior de la pantalla de inicio de sesión.

## Requisitos

- Flutter estable reciente (con Dart 3.13.1 o superior)
- Navegador moderno

## Ejecutar localmente

```bash
flutter pub get
flutter run -d chrome --web-hostname localhost --web-port 7357
```

## Datos locales y Google

En Web, las cuentas, bibliotecas, estados de lectura, favoritos e imágenes de
perfil se guardan en la base `booksmart.db` de IndexedDB del navegador. Los
datos quedan separados por cuenta y por origen/navegador; no se sincronizan
con otros dispositivos y se pueden borrar al limpiar los datos del navegador.
Las contraseñas se guardan como hashes PBKDF2, no en texto plano. Este
almacenamiento local no sustituye un servicio de autenticación o una base de
datos de servidor para producción.

El botón de Google usa el cliente OAuth Web configurado en
`lib/screens/login_screen.dart` y `web/index.html`. En Google Cloud Console,
agrega como **Authorized JavaScript origins** `http://localhost`,
`http://localhost:7357` y `https://josephjeanpiererc-svg.github.io`. No
compartas un OAuth client secret en el código del navegador.

Para Google Sign-In nativo en Android, crea además un cliente OAuth de tipo
**Android** con el package name `com.example.app_editorial` y la huella SHA-1
de depuración `98:96:8D:A6:F1:59:A4:04:EA:F4:B4:09:51:FC:61:05:57:13:98:70`.
La huella de la clave de firma de publicación debe registrarse por separado
cuando se configure. iOS requiere su propio cliente OAuth iOS y URL scheme en
`ios/Runner/Info.plist`; no se debe reutilizar ahí el cliente Web.

## Construcción web

```bash
flutter build web --release --base-href "/BookSmart/"
```

El APK de depuración se incluye en el despliegue de GitHub Pages mediante el
flujo de trabajo. Para instalarlo manualmente en un dispositivo Android, permite
la instalación desde el navegador cuando Android lo solicite.
