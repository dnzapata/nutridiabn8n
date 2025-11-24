#!/usr/bin/env node

/**
 * Script para generar hash de contraseñas con bcrypt
 * Uso: node scripts/generate-password-hash.js <contraseña>
 */

const bcrypt = require('bcrypt');

// Obtener contraseña desde argumentos
const password = process.argv[2];

if (!password) {
  console.error('\n❌ Error: Debes proporcionar una contraseña');
  console.log('\nUso: node scripts/generate-password-hash.js <contraseña>');
  console.log('Ejemplo: node scripts/generate-password-hash.js MiContraseña123\n');
  process.exit(1);
}

// Generar hash
const saltRounds = 10;
const hash = bcrypt.hashSync(password, saltRounds);

console.log('\n✅ Hash generado exitosamente:');
console.log('━'.repeat(80));
console.log(`Contraseña: ${password}`);
console.log(`Hash:       ${hash}`);
console.log('━'.repeat(80));

console.log('\n📋 SQL para insertar usuario:');
console.log('━'.repeat(80));
console.log(`
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  "username", 
  "password_hash",
  "nombre",
  "apellido",
  "email",
  "rol",
  "Activo",
  "AceptoTerminos",
  "datos_completos",
  "email_verificado"
)
VALUES (
  'usuario@nutridiab.system',
  'username_aqui',
  '${hash}',
  'Nombre',
  'Apellido',
  'email@example.com',
  'administrador',  -- o 'usuario'
  TRUE,
  TRUE,
  TRUE,
  TRUE
);
`);
console.log('━'.repeat(80) + '\n');

