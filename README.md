# Apoloprimer — plataforma de streaming colaborativa

Incluye:
- Catálogo público de películas.
- Registro e inicio de sesión.
- Panel de subida exclusivo para usuarios incluidos en `public.admins`.
- Almacenamiento de videos y portadas en Supabase Storage.
- Salas privadas mediante código de invitación.
- Chat en vivo y presencia de participantes con Supabase Realtime.
- Controles sincronizados; solo el creador de la sala puede reproducir/pausar/adelantar.

## Requisitos
1. Un proyecto Supabase.
2. Hosting estático (Railway, Netlify, Vercel o similar).
3. Dominio opcional.

## Configuración Supabase
1. Crea un proyecto en https://supabase.com.
2. En SQL Editor, ejecuta el contenido completo de `supabase-schema.sql`.
3. En Authentication, crea tu usuario con tu correo y contraseña.
4. Copia el UUID de ese usuario desde Authentication > Users.
5. En SQL Editor ejecuta, sustituyendo el UUID:
   `insert into public.admins (user_id) values ('TU-UUID');`
6. En Project Settings > API, copia Project URL y anon/public key.
7. En `index.html`, sustituye:
   - `PEGA_AQUI_TU_SUPABASE_URL`
   - `PEGA_AQUI_TU_SUPABASE_ANON_KEY`

La clave anon/public está diseñada para estar en el navegador y queda protegida por RLS. Nunca pongas `service_role` en `index.html`.

## Publicación
Sube `index.html` a un hosting estático junto con este archivo de configuración (o sirve el directorio como sitio estático). Para Railway, conecta el repositorio GitHub que contenga estos archivos. El sitio debe servir `index.html` en la raíz.

## Límites y producción
- Esta base usa subida directa de archivos con un límite configurado de 2 GB. Para películas grandes o muchos usuarios, conviene usar cargas reanudables y un proveedor de video/CDN con soporte de streaming adaptativo (HLS).
- El chat usa Realtime Broadcast y no guarda historial.
- El acceso a salas se basa en un código de invitación aleatorio de 12 caracteres. Para producción de mayor seguridad, agrega tabla de miembros, expiración de códigos, moderación y límites de mensajes.
- Los controles sincronizan órdenes; la latencia de red y diferencias de buffering pueden causar pequeños desfases.
- Configura límites de ancho de banda, almacenamiento, cuotas y facturación del proveedor antes de hacer pública la plataforma.
- Sube solo películas que tengas derecho a distribuir.

## Prueba local
Abre el sitio servido desde un servidor web local o hosting HTTPS. Algunos navegadores restringen módulos ES al abrir archivos con `file://`.
