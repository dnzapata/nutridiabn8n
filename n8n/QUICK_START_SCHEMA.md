# ⚡ Quick Start: Schema por Defecto en n8n

## 🎯 Respuesta rápida

**Sí, se puede configurar el schema por defecto en PostgreSQL para que n8n lo use automáticamente.**

---

## 🚀 Solución en 2 comandos

### 1. Configurar el usuario (ejecutar una vez)

```bash
psql -U postgres -d nutridiab -c "ALTER ROLE dnzapata SET search_path TO nutridiab, public;"
```

### 2. Reiniciar n8n

```bash
docker restart n8n
```

---

## ✅ Resultado

### Antes:
```sql
SELECT * FROM nutridiab.login_usuario('user', 'pass');
```

### Después:
```sql
SELECT * FROM login_usuario('user', 'pass');
```

---

## 📋 Comando completo

Si prefieres ejecutar el script completo con verificaciones:

```bash
psql -U postgres -d nutridiab -f database/configurar_schema_usuario.sql
```

---

## 🔍 Verificar que funciona

En n8n, crea un nodo Postgres con esta query:

```sql
SHOW search_path;
```

**Debe devolver:** `nutridiab, public`

---

## 💡 ¿Cómo funciona?

```
Usuario dnzapata conecta → PostgreSQL aplica search_path automático
                          → Busca primero en schema "nutridiab"
                          → Si no encuentra, busca en "public"
                          → n8n usa queries simplificados ✨
```

---

## 📊 Comparación

| Método | Complejidad | Permanente | Recomendado |
|--------|-------------|------------|-------------|
| ALTER ROLE | ⭐ Baja | ✅ Sí | ⭐⭐⭐⭐⭐ |
| Schema explícito | ⭐⭐ Media | ✅ Sí | ⭐⭐⭐ |
| SET en cada query | ⭐⭐⭐ Alta | ❌ No | ⭐ |

---

## 🆘 Si algo falla

```sql
-- Verificar usuario
SELECT current_user;

-- Verificar search_path
SELECT current_setting('search_path');

-- Reconfigurar si es necesario
ALTER ROLE dnzapata SET search_path TO nutridiab, public;
```

---

## 📚 Más información

- [Guía completa](CONFIGURAR_SCHEMA_POSTGRES.md)
- [Ejemplos de queries](EJEMPLOS_QUERIES_SIMPLIFICADOS.md)
- [Script automatizado](../database/configurar_schema_usuario.sql)

---

✨ **Listo! Ahora puedes usar queries más limpios en n8n.**

