#!/bin/bash

# Script de vérification du projet pour répondre au feedback
echo "=== VÉRIFICATION DU PROJET FRONT_MOBILE ==="
echo ""

echo "1. Vérification des fichiers de test (exigence: 3+ tests par repository)"
echo "-------------------------------------------------------------------"
find test -name "*_test.dart" -exec echo "   - {}" \;
echo ""
echo "   Nombre de tests dans adherents_repository_test.dart:"
grep -c "test(" test/repositories/adherents_repository_test.dart 2>/dev/null || echo "   0"
echo "   Nombre de tests dans livres_repository_test.dart:"
grep -c "test(" test/repositories/livres_repository_test.dart 2>/dev/null || echo "   0"
echo "   Nombre de tests dans auth_repository_test.dart:"
grep -c "test(" test/repositories/auth_repository_test.dart 2>/dev/null || echo "   0"
echo ""

echo "2. Vérification de analysis_options.yaml"
echo "-----------------------------------------"
if [ -f analysis_options.yaml ]; then
    echo "   ✅ analysis_options.yaml PRÉSENT"
    echo "   Contient flutter_lints:"
    grep -q "flutter_lints" analysis_options.yaml && echo "   ✅ flutter_lints activé" || echo "   ❌ flutter_lints non trouvé"
else
    echo "   ❌ analysis_options.yaml ABSENT"
fi
echo ""

echo "3. Vérification du CI/CD (GitHub Actions)"
echo "------------------------------------------"
if [ -f .github/workflows/ci.yml ]; then
    echo "   ✅ .github/workflows/ci.yml PRÉSENT"
    echo "   Contient flutter analyze:"
    grep -q "flutter analyze" .github/workflows/ci.yml && echo "   ✅ flutter analyze configuré" || echo "   ❌ flutter analyze non trouvé"
    echo "   Contient flutter test:"
    grep -q "flutter test" .github/workflows/ci.yml && echo "   ✅ flutter test configuré" || echo "   ❌ flutter test non trouvé"
else
    echo "   ❌ .github/workflows/ci.yml ABSENT"
fi
echo ""

echo "4. Vérification de l'AuthInterceptor"
echo "---------------------------------------"
if [ -f lib/core/network/auth_interceptor.dart ]; then
    echo "   ✅ auth_interceptor.dart PRÉSENT"
    echo "   Contient injection Bearer:"
    grep -q "Authorization.*Bearer" lib/core/network/auth_interceptor.dart && echo "   ✅ Injection Bearer trouvée" || echo "   ❌ Injection Bearer non trouvée"
    echo "   Contient refresh sur 401:"
    grep -q "401" lib/core/network/auth_interceptor.dart && echo "   ✅ Gestion 401 trouvée" || echo "   ❌ Gestion 401 non trouvée"
else
    echo "   ❌ auth_interceptor.dart ABSENT"
fi
echo ""

echo "5. Vérification du cache local (GetStorage)"
echo "--------------------------------------------"
if [ -f lib/core/storage/cache_storage.dart ]; then
    echo "   ✅ cache_storage.dart PRÉSENT"
else
    echo "   ❌ cache_storage.dart ABSENT"
fi
echo "   Local datasources:"
find lib/data/datasources/local -name "*.dart" -exec echo "   - {}" \;
echo ""

echo "6. Vérification du module register"
echo "-----------------------------------"
if [ -f lib/modules/register/register_view.dart ]; then
    echo "   ✅ register_view.dart PRÉSENT"
else
    echo "   ❌ register_view.dart ABSENT"
fi
if [ -f lib/modules/register/register_controller.dart ]; then
    echo "   ✅ register_controller.dart PRÉSENT"
else
    echo "   ❌ register_controller.dart ABSENT"
fi
if [ -f lib/modules/register/register_binding.dart ]; then
    echo "   ✅ register_binding.dart PRÉSENT"
else
    echo "   ❌ register_binding.dart ABSENT"
fi
echo ""

echo "7. Vérification des écrans de données"
echo "--------------------------------------"
echo "   Modules de données:"
find lib/modules -type d -mindepth 1 -maxdepth 1 | grep -v "^lib/modules/auth$" | sort
echo ""

echo "8. Vérification de Dio dans pubspec.yaml"
echo "----------------------------------------"
if grep -q "dio:" pubspec.yaml; then
    echo "   ✅ Dio PRÉSENT dans pubspec.yaml"
else
    echo "   ❌ Dio ABSENT de pubspec.yaml"
fi
echo ""

echo "9. Vérification de GetStorage dans pubspec.yaml"
echo "-----------------------------------------------"
if grep -q "get_storage:" pubspec.yaml; then
    echo "   ✅ GetStorage PRÉSENT dans pubspec.yaml"
else
    echo "   ❌ GetStorage ABSENT de pubspec.yaml"
fi
echo ""

echo "10. Vérification de FlutterSecureStorage dans pubspec.yaml"
echo "------------------------------------------------------------"
if grep -q "flutter_secure_storage:" pubspec.yaml; then
    echo "   ✅ FlutterSecureStorage PRÉSENT dans pubspec.yaml"
else
    echo "   ❌ FlutterSecureStorage ABSENT de pubspec.yaml"
fi
echo ""

echo "=== FIN DE LA VÉRIFICATION ==="
