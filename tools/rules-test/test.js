// Pruebas de firestore.rules contra el emulador de Firestore.
// Ejecutar con: npm test  (dentro de tools/rules-test)
const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc } = require('firebase/firestore');

const RULES = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);

const UID = 'uidBodas';
const EMAIL = 'bodas@javieralzahira.com';
const FAMILY = EMAIL.replaceAll('.', '_');

let passed = 0;
let failed = 0;

async function expectAllowed(name, fn) {
  try {
    await assertSucceeds(fn());
    passed++;
    console.log(`  OK    ${name}`);
  } catch (e) {
    failed++;
    console.log(`  FALLO ${name} -> ${e.message}`);
  }
}

async function expectDenied(name, fn) {
  try {
    await assertFails(fn());
    passed++;
    console.log(`  OK    ${name}`);
  } catch (e) {
    failed++;
    console.log(`  FALLO ${name} -> ${e.message}`);
  }
}

(async () => {
  const testEnv = await initializeTestEnvironment({
    projectId: 'demo-apphome',
    firestore: { rules: RULES },
  });

  try {
    await testEnv.clearFirestore();

    const yo = testEnv.authenticatedContext(UID, {
      email: EMAIL,
      email_verified: true,
    });
    const otro = testEnv.authenticatedContext('uidOtro', {
      email: 'otro@familia.com',
      email_verified: true,
    });
    const anon = testEnv.unauthenticatedContext();

    console.log('Familia por email');
    await expectAllowed('escribe en su familia', () =>
      setDoc(doc(yo.firestore(), `familias/${FAMILY}/miembros/123`), {
        nombre: 'A',
      }),
    );
    await expectAllowed('lee su familia', () =>
      getDoc(doc(yo.firestore(), `familias/${FAMILY}/gestion/datos`)),
    );
    await expectDenied('no lee familia ajena', () =>
      getDoc(doc(yo.firestore(), 'familias/otro@familia_com/miembros/123')),
    );
    await expectDenied('no escribe familia ajena', () =>
      setDoc(doc(yo.firestore(), 'familias/otro@familia_com/miembros/123'), {
        nombre: 'X',
      }),
    );

    console.log('Sin sesión');
    await expectDenied('anónimo no lee', () =>
      getDoc(doc(anon.firestore(), `familias/${FAMILY}/miembros/123`)),
    );
    await expectDenied('anónimo no escribe', () =>
      setDoc(doc(anon.firestore(), `familias/${FAMILY}/miembros/999`), {
        nombre: 'X',
      }),
    );

    console.log('Ruta legacy usuarios/{uid}');
    await expectAllowed('escribe su propio usuarios/{uid}', () =>
      setDoc(doc(yo.firestore(), `usuarios/${UID}/perfil/datos`), { a: 1 }),
    );
    await expectDenied('no escribe usuarios de otro', () =>
      setDoc(doc(yo.firestore(), 'usuarios/uidOtro/perfil/datos'), { a: 1 }),
    );

    console.log('familyId = uid');
    await expectAllowed('acepta familyId igual al uid', () =>
      setDoc(doc(yo.firestore(), `familias/${UID}/miembros/1`), {
        nombre: 'B',
      }),
    );

    console.log('Otro usuario autenticado');
    await expectAllowed('otro usuario escribe su familia', () =>
      setDoc(doc(otro.firestore(), 'familias/otro@familia_com/miembros/1'), {
        nombre: 'C',
      }),
    );
  } finally {
    await testEnv.cleanup();
  }

  console.log(`\n${passed} correctas, ${failed} fallidas`);
  process.exit(failed === 0 ? 0 : 1);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
